Date: Tue, 24 Feb 2004 15:38:58 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: LTP VM test slower under 2.6.3 than 2.4.20
Message-Id: <20040224153858.77692658.akpm@osdl.org>
In-Reply-To: <403B6905.2010505@movaris.com>
References: <40363778.20900@movaris.com>
	<20040222231903.5f9ead5c.akpm@osdl.org>
	<403A2F89.4070405@movaris.com>
	<403B6905.2010505@movaris.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kirk True <kirk@movaris.com>
Cc: kernelnewbies@nl.linux.org, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Kirk True <kirk@movaris.com> wrote:
>
> I just upgraded to 2.6.3-mm2 but am still seeing a factor of two speed
> slowdown between 2.4.20 and 2.6.3-mm2 for both sequential and random
> memory accesses into 1024 MB allocated from malloc.

2.6 VM has problems, but is usually OK for single-task stuff.

You'd need to tell us a lot about your machine, and provide sufficient
information for others to reproduce what you're seeing.

And run some other tests to verify that your disk system is achieving the
same bandwidth under both kernels.  Not `hdparm -t' please, it is crap. 
Something like

	time (dd if=/dev/zero of=/mnt/x/foo bs=1M count=2000 ; sync)
	umount /mnt/x
	mount /mnt/x
	time dd if=/mnt/x/foo of=/dev/null bs=1M

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
