MIME-Version: 1.0
Message-ID: <OFB80C4920.9805CF81-ONC1256D2F.002DD76B-C1256D2F.003304EE@rm>
From: Knut.Beneke@smiths-heimann.com
Date: Fri, 23 May 2003 11:11:46 +0200
Subject: How do I calculate the free memory with kernel 2.4.19?
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!
I am writing a program which needs to calculate the actual free memory to 
determine if it can start a memory intensive evaluation.
Until now we used a linux system with 2.2.17 kernel, here you could 
determine the free memory via /proc/meminfo:
real free memory = free + buffers + cached
Now we use a Mandrake 2.4.19 kernel and the values in /proc/meminfo look 
strange: free and buffers seem to mean the same as with kernel 2.2.17, but 
the cached value is much higher.
Example:
cat /proc/meminfo
        total:    used:    free:  shared: buffers:  cached:
Mem:  262221824 204009472 58212352        0  9121792 156876800
Swap:        0        0        0
MemTotal:       256076 kB
MemFree:         56848 kB
MemShared:           0 kB
Buffers:          8908 kB
Cached:         153200 kB
SwapCached:          0 kB
Active:          16848 kB
Inactive:       167112 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:       256076 kB
LowFree:         56848 kB
SwapTotal:           0 kB
SwapFree:            0 kB
The machine has 256MB physical memory, no swap. At the moment our 
application is running, using about 150-200MB, some of it is shared memory 
(at least 128MB).
The sum of free + buffers + cached = 218956kB is much to high!
so, ... How do I calculate the real free memory and what does the cached 
value mean?
Any help is appreciated!
Knut Beneke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
