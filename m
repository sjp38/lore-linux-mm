Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7B95A6B0087
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 11:44:26 -0500 (EST)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p0AGiNGF004821
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 08:44:24 -0800
Received: by iyj17 with SMTP id 17so19286964iyj.14
        for <linux-mm@kvack.org>; Mon, 10 Jan 2011 08:44:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1101091110520.5270@tiger>
References: <alpine.DEB.2.00.1101091110520.5270@tiger>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 10 Jan 2011 08:44:03 -0800
Message-ID: <AANLkTim0UBNG6bVgBDQsrBhVjS0FSdLbwaipBZGkTeWF@mail.gmail.com>
Subject: Re: [GIT PULL] SLAB changes for v2.6.38
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jan 9, 2011 at 1:13 AM, Pekka Enberg <penberg@kernel.org> wrote:
>
> It's been rather quiet for slab allocators this merge cycle. There's only
> few cleanups here. The bug fixes were merged in v2.6.37 already. As they
> were cherry-picked from this branch, they show up in the pull request
> (what's up with that btw).

For the "what's up with that btw" department:

A cherry-pick really is nothing but "apply the same patch as a
different commit".

So there is no way to say "this is already there" - because it really
isn't. It's a totally different thing. In fact, it would be very wrong
to filter them out, both from a fundamental design standpoint, but
also from a usability/reliability standpoint: cherry-picks are by no
means guaranteed to be identical to the source - like any "re-apply
the patch in another place" model, the end result is not at all
guaranteed to be semantically identical simply due to different bases:
the patches may not even be identical, and even if they are, the
results of the code may depend on what else is going on.

So don't think of cherry-picks as "the same commit". It's not, and it
never will be. It's a totally separate commit, they just share some
superficial commonalities.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
