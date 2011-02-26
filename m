Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5B2FC8D0039
	for <linux-mm@kvack.org>; Sat, 26 Feb 2011 07:45:43 -0500 (EST)
Date: Sat, 26 Feb 2011 13:37:13 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/5] exec: introduce "bool compat" argument
Message-ID: <20110226123713.GB4416@redhat.com>
References: <20101130200129.GG11905@redhat.com> <compat-not-unlikely@mdm.bga.com> <20101201182747.GB6143@redhat.com> <20110225175202.GA19059@redhat.com> <20110225175249.GC19059@redhat.com> <AANLkTinY3QbtZx=2Vo=pCy-b0z_BXK1f1AqXYwNg_Sje@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTinY3QbtZx=2Vo=pCy-b0z_BXK1f1AqXYwNg_Sje@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

On 02/25, Linus Torvalds wrote:
>
> On Fri, Feb 25, 2011 at 9:52 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> > No functional changes, preparation to simplify the review.
>
> I think this is wrong.
>
> If you introduce the "bool compat" thing, you should also change the
> type of the argument pointers to some opaque type at the same time.
> It's no longer really a
>
>   const char __user *const __user *
>
> pointer at that point. Trying to claim it is, is just wrong. The type
> suddently becomes conditional on that 'compat' variable.

Yes, this is true.

And I agree this could be done in more clean way, just we need more
changed. Please see the next email.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
