Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id ECED16B004D
	for <linux-mm@kvack.org>; Sat, 10 Dec 2011 14:52:55 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: XFS causing stack overflow
References: <CAAnfqPAm559m-Bv8LkHARm7iBW5Kfs7NmjTFidmg-idhcOq4sQ@mail.gmail.com>
	<20111209115513.GA19994@infradead.org>
	<20111209221956.GE14273__25752.826271537$1323469420$gmane$org@dastard>
Date: Sat, 10 Dec 2011 11:52:51 -0800
In-Reply-To: <20111209221956.GE14273__25752.826271537$1323469420$gmane$org@dastard>
	(Dave Chinner's message of "Sat, 10 Dec 2011 09:19:56 +1100")
Message-ID: <m262hop5kc.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, xfs@oss.sgi.com, "Ryan C. England" <ryan.england@corvidtec.com>

Dave Chinner <david@fromorbit.com> writes:
>
> You forgot about interrupt stacking - that trace shows the system
> took an interrupt at the point of highest stack usage in the
> writeback call chain.... :/

The interrupts are always running on other stacks these days
(even 32bit got switched over).

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
