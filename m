Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E31D46B0083
	for <linux-mm@kvack.org>; Fri, 30 Jan 2009 22:54:00 -0500 (EST)
References: <715599.77204.qm@web50111.mail.re2.yahoo.com>
	<m1wscc7fop.fsf@fess.ebiederm.org> <49836114.1090209@buttersideup.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 30 Jan 2009 19:54:05 -0800
In-Reply-To: <49836114.1090209@buttersideup.com> (Tim Small's message of "Fri\, 30 Jan 2009 20\:20\:36 +0000")
Message-ID: <m1iqnw1676.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: marching through all physical memory in software
Sender: owner-linux-mm@kvack.org
To: Tim Small <tim@buttersideup.com>
Cc: Doug Thompson <norsk5@yahoo.com>, ncunningham-lkml@crca.org.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chris Friesen <cfriesen@nortel.com>, Pavel Machek <pavel@suse.cz>, bluesmoke-devel@lists.sourceforge.net, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

Tim Small <tim@buttersideup.com> writes:

> Eric W. Biederman wrote:
>> A background software scrubber simply has the job of rewritting memory
>> to it's current content so that the data and the ecc check bits are
>> guaranteed to be in sync
>
> Don't you just need to READ memory?  The memory controller hardware takes care
> of the rest in the vast majority of cases.
>
> You only need to rewrite RAM if a correctable error occurs, and the chipset
> doesn't support automatic write-back of the corrected value (a different problem
> altogether...).  The actual memory bits themselves are refreshed by the hardware
> quite frequently (max of every 64ms for DDR2, I believe)...

At the point we are talking about software scrubbing it makes sense to assume
a least common denominator memory controller, one that does not do automatic
write-back of the corrected value, as all of the recent memory controllers
do scrubbing in hardware.

Once you handle the stupidest hardware all other cases are just software optimizations
on that, and we already have the tricky code that does a read-modify-write without
changing the contents of memory, so guarantees everything it touches will be written
back.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
