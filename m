Received: by wa-out-1112.google.com with SMTP id j37so1027294waf.22
        for <linux-mm@kvack.org>; Sat, 29 Nov 2008 21:21:02 -0800 (PST)
Message-ID: <2f11576a0811292121o42a5feaetdd46e31885c13644@mail.gmail.com>
Date: Sun, 30 Nov 2008 14:21:02 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH/RFC] - support inheritance of mlocks across fork/exec
In-Reply-To: <1227998319.7489.30.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1227561707.6937.61.camel@lts-notebook>
	 <20081126172913.3CB8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1227998319.7489.30.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Hi

> Hello, Kosaki-san:
>
> Thanks for looking at this.  I think you mean that:
>
> 1) don't allow MCL_INHERIT | MCL_RECURSIVE without either MCL_CURRENT or
> MCL_FUTURE, and
>
> 2) MCL_RECURSIVE without MCL_INHERIT does not make sense, either.
>
> Is this correct?

Yup. you describe just my opnion.
thanks.


> I guess I agree with you.  As is stands, my patch would allow
> MCL_INHERIT[|MCL_RECURSIVE] to sneak through with neither MCL_CURRENT
> nor MCL_FUTURE set.  Looks like this would result in mlock_fixup() being
> called with a newflags that does not containing VM_LOCKED.  This would
> be treated as munlockall().   Not good.  Your first check would catch
> this.
>
> The second condition would be a no-op, I think.  We only look at look
> for MCL_RECURSIVE in mm->mcl_inherit when mcl_inherit is non-zero; and
> we only set mcl_inherit when MCL_INHERIT is specified.  But, if the
> caller specified MCL_RECURSIVE, they probably intended something to
> happen, and since it won't, best to return an error.
>
> I'll fix this up and send it out to the wider distribution that Andrew
> requested.
>
> Thanks, again.

I am one of most appointee from this patch :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
