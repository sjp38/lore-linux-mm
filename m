Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 8EBE16B006C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 12:28:20 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id dq11so6770278wgb.14
        for <linux-mm@kvack.org>; Wed, 02 Jan 2013 09:28:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFyH63agfbf+pYNRGHaprPqAJF=F19GR6ASP_RhoyDGLdA@mail.gmail.com>
References: <alpine.LNX.2.00.1301020153090.18049@eggly.anvils>
 <0000013bfbfbb293-ccc455ed-2db6-46e2-8362-dc418bae0def-000000@email.amazonses.com>
 <CA+55aFyH63agfbf+pYNRGHaprPqAJF=F19GR6ASP_RhoyDGLdA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 2 Jan 2013 09:27:58 -0800
Message-ID: <CA+55aFxx6dj1Uzr4gUw2o-xYWpTkhaQ6LBSGnp16GC35gHs0_Q@mail.gmail.com>
Subject: Re: [PATCH 1/2] tmpfs mempolicy: fix /proc/mounts corrupting memory
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, Jan 2, 2013 at 9:24 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Anyway, I do not know why Hugh took the true case, but I don't really
> imagine that it matters. So I'll take these two patches, but it would
> be good if you double-checked this, Hugh.

Oh, Hugh actually even mentioned it in the commit message. So never mind.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
