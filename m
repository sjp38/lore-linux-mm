Date: Thu, 13 Jan 2005 22:06:25 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: smp_rmb in mm/memory.c in 2.6.10
Message-ID: <20050113210624.GG20738@wotan.suse.de>
References: <20050113203954.GA6101@holomorphy.com> <20050113210210.51593.qmail@web14323.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050113210210.51593.qmail@web14323.mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanojsarcar@yahoo.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> In include/asm-i386/spinlock.h, spin_unlock_string has
> a "xchgb" (in case its required). That should be
> enough  of a barrier for the hardware, no? 

It is, but only for broken PPros or OOSTORE system
(currently only VIA C3). For kernels compiled for non broken CPUs  
there isn't any kind of barrier. 

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
