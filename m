Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 4AD066B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 10:33:29 -0400 (EDT)
Date: Fri, 18 May 2012 16:33:15 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] lib: Proportions with flexible period
Message-ID: <20120518143315.GB6875@quack.suse.cz>
References: <1337096583-6049-1-git-send-email-jack@suse.cz>
 <1337096583-6049-2-git-send-email-jack@suse.cz>
 <1337290512.4281.91.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1337290512.4281.91.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu 17-05-12 23:35:12, Peter Zijlstra wrote:
> On Tue, 2012-05-15 at 17:43 +0200, Jan Kara wrote:
> > +               if (numerator > ((long long)denominator) * max_frac / 100)
> 
> Does that even compile on 32bit archs?
> 
> Operator precedence is *,/ left-to-right, so that's:
> 
>   long long t1 = (long long)denom * max_frac
>   long long t2 = t1 / 100;
> 
> Which is a 64bit signed division.
> 
> There's a reason I used that max_prop_frac thing you removed, it avoids
> having to do the division at all and allows a mult and shift instead.
  Yeah, I misunderstood it's purpose when I read the code originally. I'll
put it back to avoid the division since this is a hot path.

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
