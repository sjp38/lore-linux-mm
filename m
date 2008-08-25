Message-ID: <48B2D615.4060509@linux-foundation.org>
Date: Mon, 25 Aug 2008 10:56:05 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: oom-killer why ?
References: <48B296C3.6030706@iplabs.de>
In-Reply-To: <48B296C3.6030706@iplabs.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marco Nietz <m.nietz-mm@iplabs.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marco Nietz wrote:

> DMA32: empty
> Normal: 0*4kB 0*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB 1*512kB
> 1*1024kB 1*2048kB 0*4096kB = 3664kB

If the flags are for a regular allocation then you have had a something that
leaks kernel memory (device driver?). Can you get us the output of
/proc/meminfo and /proc/vmstat?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
