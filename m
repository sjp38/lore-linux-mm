Subject: Re: [PATCH] Re: simple FS application that hangs 2.4-test5, mem mgmt
 problem or FS buffer cache mgmt problem?
Message-ID: <OF60FE3F76.1D86D74A-ON88256951.005C4476@LocalDomain>
From: "Ying Chen/Almaden/IBM" <ying@almaden.ibm.com>
Date: Tue, 5 Sep 2000 10:02:44 -0700
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
ReSent-To: linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
ReSent-Message-ID: <Pine.LNX.4.21.0009051408490.15605@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Ok. I got some alt-sysrq-m output from my SPEC SFS test. But the problem
was new.
Here is a description of the problem, and the alt-sysrq-m output.

I was trying to run SPEC SFS test with high IOPS like what I did before.
This time it's not the SPEC SFS server that died, but the client, which
ran 2.4-test6smp. The client machine is a 2-way IBM Intellistation M Pro
with 400 MHz P II, with 1GB memory.
My 2-way did not seem to die hard, i.e., somehow VM is still trying to kill
various processes. I got console messages like " VM: killing process sfs"
once in a while (since I have multiple sfs threads, I guess). But I cannot
do anything when it was spitting messages out.

I did alt-sysrq-m then. Here is the output:

SysRq: Show Memory
Mem-info:
Free Pages: 1740 kB (0 kB HighMem)
(Free: 435, lru-cache: 2818 (256 512 768) )
 M11 DMA: 4 * 4kB 3 * 8kB 2 * 16 kB 2 * 32 kB 3 * 64 kB 1 * 128 kB 1 * 256
kB 0 * 1024 KB 0 * 2048 kB = 712 kB)
 M 11 Normal: 3 * 4 kB 1 * 8 kB 1 * 16 kB 1 * 32 kB 1 * 64 kB  1 * 128 kB 1
* 256 kB 1 * 512 kB 0 * 1024 kB 0 * 2048 kB = 1024 kB)
 L00 HighMem = 0kB)
Swap cache: add 37995, delete 37995, find 1274/7279
Free swap: 0kB
229376 pages of RAM
0 pages of HIGHMEM
5194 reserved pages
170 pages shared
0 pages swap cached
0 pages in page table cache
Buffer memory: 80 kB
     CLEAN: 26 buffers, 26 kbyte, 9 used (last = 11), 0 locked, 0
protected, 0 dirty
     LOCKED: 54 buffers, 54 kbyte, 31 used (last = 54), 0 locked, 0
protected, 0 dirty


Ying Chen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
