Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5F28F6B00E7
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 05:41:19 -0500 (EST)
Received: by gwj22 with SMTP id 22so9408535gwj.14
        for <linux-mm@kvack.org>; Tue, 11 Jan 2011 02:41:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTim0UBNG6bVgBDQsrBhVjS0FSdLbwaipBZGkTeWF@mail.gmail.com>
References: <alpine.DEB.2.00.1101091110520.5270@tiger>
	<AANLkTim0UBNG6bVgBDQsrBhVjS0FSdLbwaipBZGkTeWF@mail.gmail.com>
Date: Tue, 11 Jan 2011 12:41:17 +0200
Message-ID: <AANLkTi=pvz-ou3_DK0dUSRYCARkwM_X9x7Xpnapjw_Ke@mail.gmail.com>
Subject: Re: [GIT PULL] SLAB changes for v2.6.38
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

On Mon, Jan 10, 2011 at 6:44 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> A cherry-pick really is nothing but "apply the same patch as a
> different commit".
>
> So there is no way to say "this is already there" - because it really
> isn't. It's a totally different thing. In fact, it would be very wrong
> to filter them out, both from a fundamental design standpoint, but
> also from a usability/reliability standpoint: cherry-picks are by no
> means guaranteed to be identical to the source - like any "re-apply
> the patch in another place" model, the end result is not at all
> guaranteed to be semantically identical simply due to different bases:
> the patches may not even be identical, and even if they are, the
> results of the code may depend on what else is going on.
>
> So don't think of cherry-picks as "the same commit". It's not, and it
> never will be. It's a totally separate commit, they just share some
> superficial commonalities.

OK, I did not know that. Thanks for the explanation!

Is cherry pick still sane from maintainer workflow point of view? I
used to do it the other way - merge bug fixes to an "urgent branch"
and then merge that to the "next branch". I changed my workflow to
apply the patches always to the "next branch" first and only cherry
pick to the "urgent branch" if necessary.

Am I doing it wrong?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
