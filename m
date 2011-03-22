Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D7EA08D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 16:35:16 -0400 (EDT)
Message-ID: <4D8907C2.7010304@fiec.espol.edu.ec>
Date: Tue, 22 Mar 2011 15:34:10 -0500
From: =?ISO-8859-1?Q?Alex_Villac=ED=ADs_Lasso?=
 <avillaci@fiec.espol.edu.ec>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
References: <4D839EDB.9080703@fiec.espol.edu.ec> <20110319134628.GG707@csn.ul.ie> <4D84D3F2.4010200@fiec.espol.edu.ec> <20110319235144.GG10696@random.random> <20110321094149.GH707@csn.ul.ie> <20110321134832.GC5719@random.random> <20110321163742.GA24244@csn.ul.ie> <4D878564.6080608@fiec.espol.edu.ec> <20110321201641.GA5698@random.random> <20110322112032.GD24244@csn.ul.ie> <20110322150314.GC5698@random.random>
In-Reply-To: <20110322150314.GC5698@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

El 22/03/11 10:03, Andrea Arcangeli escribio:
>
> I asked yesterday by PM to Alex if the mouse pointer moves or not
> during the stalls (if it doesn't that may be a scheduler issue with
> the compaction irq disabled and lack of cond_resched) and to try
> aa.git. Upstream still misses several compaction improvements that we
> did over the last weeks and that I've in my queue and that are in -mm
> as well. So before making more changes, considering the stack traces
> looks very healthy now, I'd wait to be sure the hangs aren't already
> solved by any of the other scheduling/irq latency fixes. I guess they
> aren't going to help but it worth a try. Verifying if this happens
> with a more optimal filesystem like ext4 I think is also interesting,
> it may be something in udf internal locking that gets in the way of
> compaction.
>
> If we still have a problem with current aa.git and ext4, then I'd hope
> we can find some other more genuine bit to improve like the bits we've
> improved so far, but if there's nothing wrong and it gets unfixable,
> then my preference would be to either create a defrag mode that is in
> between "yes/no", or alternatively to be simpler and make the default
> between defrag yes|no configurable at build time and through a command
> line in grub, and hope that SLUB doesn't clashes on it too. The
> current "default" is optimal for several server environments where we
> know most of the allocations are long lived. So we want to still have
> an option to be as reliable as we are toady for those.
>
I have just tested aa.git as of today, with the USB stick formatted as FAT32. I could no longer reproduce the stalls. There was no need to format as ext4. No /proc workarounds required.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
