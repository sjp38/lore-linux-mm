From: "Abu M. Muttalib" <abum@aftek.com>
Subject: the /proc/meminfo statistics
Date: Tue, 1 Aug 2006 15:09:32 +0530
Message-ID: <BKEKJNIHLJDCFGDBOHGMEEJDDEAA.abum@aftek.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org, linux-newbie@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I am running the following application.

#include<stdio.h>
#include<stdlib.h>

int main()
{
	unsigned char* arr;
	system("cat /proc/meminfo");
	sleep(25);
	arr = (char *)malloc (1048576);
	system("cat /proc/meminfo");
	sleep(25);
	free(arr);
	system("cat /proc/meminfo");
	sleep(25);
}

I am getting the following meminfo statistics. As I am allocating and
freeing 1024 kb, so I should get the same information through /proc/meminfo:


MemTotal:        14296 kB
MemFree:           912 kB
Buffers:          1448 kB
Cached:           5564 kB
SwapCached:          0 kB
Active:           5480 kB
Inactive:         3664 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:        14296 kB
LowFree:           912 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:               0 kB
Writeback:           0 kB
Mapped:           5144 kB
Slab:             1560 kB
CommitLimit:      7148 kB
Committed_AS:     6492 kB
PageTables:        188 kB
VmallocTotal:   630784 kB
VmallocUsed:    262560 kB
VmallocChunk:   366588 kB


MemTotal:        14296 kB
MemFree:           920 kB
Buffers:          1448 kB
Cached:           5564 kB
SwapCached:          0 kB
Active:           5492 kB
Inactive:         3660 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:        14296 kB
LowFree:           920 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:               0 kB
Writeback:           0 kB
Mapped:           5152 kB
Slab:             1544 kB
CommitLimit:      7148 kB
Committed_AS:     7652 kB
PageTables:        188 kB
VmallocTotal:   630784 kB
VmallocUsed:    262560 kB
VmallocChunk:   366588 kB


MemTotal:        14296 kB
MemFree:           924 kB
Buffers:          1448 kB
Cached:           5564 kB
SwapCached:          0 kB
Active:           5488 kB
Inactive:         3660 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:        14296 kB
LowFree:           924 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:               0 kB
Writeback:           0 kB
Mapped:           5148 kB
Slab:             1544 kB
CommitLimit:      7148 kB
Committed_AS:     6624 kB
PageTables:        188 kB
VmallocTotal:   630784 kB
VmallocUsed:    262560 kB
VmallocChunk:   366588 kB

I think that the values given in first Committed_AS and 3rd Committed_AS
should be same. But the same is not the case. Why its so?

Anticipation and regards,
Abu.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
