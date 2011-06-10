Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CB2416B0012
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 18:31:19 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p5AMV6OT004712
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 15:31:11 -0700
Received: from pwi8 (pwi8.prod.google.com [10.241.219.8])
	by kpbe16.cbf.corp.google.com with ESMTP id p5AMUgEc030219
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 15:30:48 -0700
Received: by pwi8 with SMTP id 8so1706080pwi.8
        for <linux-mm@kvack.org>; Fri, 10 Jun 2011 15:30:37 -0700 (PDT)
Date: Fri, 10 Jun 2011 15:30:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
 instead of failing
In-Reply-To: <20110610222020.GP24424@n2100.arm.linux.org.uk>
Message-ID: <alpine.DEB.2.00.1106101526390.24646@chino.kir.corp.google.com>
References: <alpine.LFD.2.02.1106012134120.3078@ionos> <4DF1C9DE.4070605@jp.fujitsu.com> <20110610004331.13672278.akpm@linux-foundation.org> <BANLkTimC8K2_H7ZEu2XYoWdA09-3XxpV7Q@mail.gmail.com> <20110610091233.GJ24424@n2100.arm.linux.org.uk>
 <alpine.DEB.2.00.1106101150280.17197@chino.kir.corp.google.com> <20110610185858.GN24424@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1106101456080.23076@chino.kir.corp.google.com> <20110610220748.GO24424@n2100.arm.linux.org.uk>
 <alpine.DEB.2.00.1106101510000.23076@chino.kir.corp.google.com> <20110610222020.GP24424@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, pavel@ucw.cz

On Fri, 10 Jun 2011, Russell King - ARM Linux wrote:

> So those platforms which don't have a DMA zone, don't have any problems
> with DMA, yet want to use the very same driver which does have a problem
> on ISA hardware have to also put up with a useless notification that
> their kernel might be broken?
> 
> Are you offering to participate on other architectures mailing lists to
> answer all the resulting queries?
> 

It all depends on the wording of the "warning", it should make it clear 
that this is not always an error condition and only affects certain types 
of hardware which the user may or may not have.  If you have any 
suggestions on how to alter "task (pid): attempted to allocate DMA memory 
without DMA support -- enable CONFIG_ZONE_DMA if needed" to make that more 
clear, be my guest.  The alternative is that the ISA hardware cannot 
handle the memory returned fails unexpectedly and randomly without any 
clear indication of what the issue is.  I think what would be worse is 
time lost for someone to realize CONFIG_ZONE_DMA isn't enabled, and that 
could be significant (and probably generate many bug reports on its own) 
since it isn't immediately obvious without doing some debugging.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
