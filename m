Subject: Re: New mm and highmem reminder
References: <Pine.LNX.4.21.0010251601120.943-100000@duckman.distro.conectiva>
From: Christoph Rohland <cr@sap.com>
Date: 25 Oct 2000 22:08:10 +0200
In-Reply-To: Rik van Riel's message of "Wed, 25 Oct 2000 16:02:01 -0200 (BRDT)"
Message-ID: <m3snpkelat.fsf@linux.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Rik,

Rik van Riel <riel@conectiva.com.br> writes:

> On 25 Oct 2000, Christoph Rohland wrote:
> 
> Could you test if /normal/ swapping works on highmem
> machines?

I tested this by mmaping named files instead of shm files. The machine
does not lock up and does not swap because the processes are stuck
uninteruptible and ps and vmstat do lock up on them.

I can else work on the machine

[root@ls3016 /root]# cat /proc/meminfo
         total:    used:    free:  shared: buffers:  cached: 
Mem:  4144390144 3957956608 186433536        0  9175040 3708989440 
Swap: 2048053248        0 2048053248 
MemTotal:      8241560 kB 
MemFree:        182064 kB 
MemShared:           0 kB 
Buffers:          8960 kB 
Cached:        7816364 kB 
Active:        5031424 kB 
Inact_dirty:   2793900 kB 
Inact_clean:         0 kB 
Inact_target:    21936 kB 
HighTotal:     7471104 kB 
HighFree:         2036 kB 
LowTotal:       770456 kB 
LowFree:        180028 kB 
SwapTotal:     2000052 kB 
SwapFree:      2000052 kB 


later:

Active:        5029908 kB
Inact_dirty:   2795424 kB
Inact_clean:         0 kB
Inact_target:     6528 kB                                       

Greetings
                Christoph

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
