#!/usr/bin/awk -f

/^\s+mixed/ {
	mcnt++;
	split($4, a, "=");
	split(a[2], b, ",");
	miops += b[1];
	msqsum += b[1] ** 2;
}

/^\s+read/ {
	rcnt++;
	split($4, a, "=");
	split(a[2], b, ",");
	riops += b[1];
	rsqsum += b[1] ** 2;
}

/^\s+write/ {
	wcnt++;
	split($4, a, "=");
	split(a[2], b, ",");
	wiops += b[1];
	wsqsum += b[1] ** 2;
}

END {
	if (mcnt > 0) {
		mavg = miops/mcnt;
		mstdev  = sqrt((msqsum/mcnt) - mavg ** 2);
		printf "Mixed: avg: %.4f stdev: %.4f\n", mavg, mstdev;
	}
	if (rcnt > 0) {
		ravg = riops/rcnt;
		rstdev = sqrt((rsqsum/rcnt) - ravg**2);
		printf "read: avg: %.4f stdev: %.4f\n", ravg, rstdev;
	}
	if (wcnt > 0) {
		wavg = wiops/wcnt;
		wstdev = sqrt((wsqsum/wcnt) - wavg**2);
		printf "write: avg: %.4f stdev: %.4f\n", wavg, wstdev;
	}
}
