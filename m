Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id D16A16B00AA
	for <linux-mm@kvack.org>; Sun, 11 Dec 2011 21:31:32 -0500 (EST)
Date: Mon, 12 Dec 2011 03:31:30 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: XFS causing stack overflow
Message-ID: <20111212023130.GI24062@one.firstfloor.org>
References: <CAAnfqPAm559m-Bv8LkHARm7iBW5Kfs7NmjTFidmg-idhcOq4sQ@mail.gmail.com> <20111209115513.GA19994@infradead.org> <20111209221956.GE14273__25752.826271537$1323469420$gmane$org@dastard> <m262hop5kc.fsf@firstfloor.org> <20111210221345.GG14273@dastard> <20111211000036.GH24062@one.firstfloor.org> <20111211230511.GH14273@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111211230511.GH14273@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, xfs@oss.sgi.com, "Ryan C. England" <ryan.england@corvidtec.com>

> But that happens before do_IRQ is called, so what is the do_IRQ call
> chain doing on this stack given that we've already supposed to have
> switched to the interrupt stack before do_IRQ is called?

Not sure I understand the question.

The pt_regs are on the original stack (but they are quite small), all the rest 
is on the new stack. ISTs are not used for interrupts, only for 
some special exceptions. do_IRQ doesn't switch any stacks on 64bit.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
