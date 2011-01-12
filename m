Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1B5D56B00E7
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 10:03:32 -0500 (EST)
Date: Wed, 12 Jan 2011 16:02:46 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: qemu-kvm defunct due to THP [was: mmotm 2011-01-06-15-41
 uploaded]
Message-ID: <20110112150246.GX9506@random.random>
References: <201101070014.p070Egpo023959@imap1.linux-foundation.org>
 <4D2B19C5.5060709@gmail.com>
 <20110110150128.GC9506@random.random>
 <4D2B73FA.807@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D2B73FA.807@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Jiri Slaby <jirislaby@gmail.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 10, 2011 at 10:02:50PM +0100, Jiri Slaby wrote:
> Yup, this works for me. If you point me to the other 2, I will test them
> too...

Sure, and they're already included in -mm.

http://marc.info/?l=linux-mm&m=129442647907831&q=raw
http://marc.info/?l=linux-mm&m=129442718808733&q=raw
http://marc.info/?l=linux-mm&m=129442733108913&q=raw

I also included in aa.git the other fixes for migrate deadlocks
(anon_vma huge non-huge probably only reproducible with preempt but
theoretically not only preempt issues, lock_page readahead with slub,
and ksm-lru-drain accounting fix for one ltp ksm testcase) if you want
to test that too (they're in -mm as well of course).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
