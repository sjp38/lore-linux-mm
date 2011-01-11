Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B2BF06B0092
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 16:25:19 -0500 (EST)
Received: by iyj17 with SMTP id 17so20557692iyj.14
        for <linux-mm@kvack.org>; Tue, 11 Jan 2011 13:25:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTiknwXJF+pLJFQPqa7XPywi=boz-H+_JLk-T+Zp8@mail.gmail.com>
References: <alpine.DEB.2.00.1101091110520.5270@tiger>
	<AANLkTim0UBNG6bVgBDQsrBhVjS0FSdLbwaipBZGkTeWF@mail.gmail.com>
	<AANLkTi=pvz-ou3_DK0dUSRYCARkwM_X9x7Xpnapjw_Ke@mail.gmail.com>
	<AANLkTiknwXJF+pLJFQPqa7XPywi=boz-H+_JLk-T+Zp8@mail.gmail.com>
Date: Tue, 11 Jan 2011 13:25:17 -0800
Message-ID: <AANLkTim29V8-w23zc=akW+F3CW-BKYR=jpWRVnr3x4E0@mail.gmail.com>
Subject: Re: [GIT PULL] SLAB changes for v2.6.38
From: Tony Luck <tony.luck@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 11, 2011 at 8:13 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:

> That said, "number of commits" is not a really meaningful measure
> either. I really tend to like how the ACPI tree does things, with
> separate branches for separate bugzilla entries - with nice relevant
> branch naming (bug number or description) - and then merging them. At
> that point you may well have a branch with just a single commit in it,
> but now the extra merge actually _adds_ information and the history
> looks better for it.

There are some notes on this work flow in the git sources in
Documentation/user-manual.txt in the [[maintaining-topic-branches]]
chapter.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
