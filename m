Message-ID: <4794C4EB.8090309@qumranet.com>
Date: Mon, 21 Jan 2008 18:14:35 +0200
From: Izik Eidus <izike@qumranet.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 4/5] example for userspace scanner
Content-Type: multipart/mixed;
 boundary="------------010408090705060407070309"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kvm-devel <kvm-devel@lists.sourceforge.net>, andrea@qumranet.com, avi@qumranet.com, dor.laor@qumranet.com, linux-mm@kvack.org, yaniv@qumranet.com
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010408090705060407070309
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


-- 
woof.


--------------010408090705060407070309
Content-Type: text/x-csrc;
 name="ksmscan.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ksmscan.c"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include "linux/ksm.h"

int main()
{
	int fd;
	int fd_scan;
	int r;

	fd = open("/dev/ksm", O_RDWR | O_TRUNC, (mode_t)0600);
	if (fd == -1) {
		fprintf(stderr, "couldnt even open it\n");
		exit(1);
	}

	fd_scan = ioctl(fd, KSM_CREATE_SCAN);
	if (fd_scan == -1) {
		printf("KSM_CREATE_SCAN failed\n");
		exit(1);
	}
	printf("created scanner!\n");

	while(1) {
		r = ioctl(fd_scan, KSM_SCAN, 100);
		usleep(1000);
	}
	return 0;
}

--------------010408090705060407070309--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
