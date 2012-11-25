Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 5A7076B005A
	for <linux-mm@kvack.org>; Sun, 25 Nov 2012 01:07:13 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id c14so1620541ieb.14
        for <linux-mm@kvack.org>; Sat, 24 Nov 2012 22:07:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1353083121-4560-5-git-send-email-mingo@kernel.org>
References: <1353083121-4560-1-git-send-email-mingo@kernel.org>
	<1353083121-4560-5-git-send-email-mingo@kernel.org>
Date: Sun, 25 Nov 2012 11:37:12 +0530
Message-ID: <CAMjzKwUMJPcf5haBKs5eqczh68W_Ur8q4dcy=dPFW2xb9-Xn2g@mail.gmail.com>
Subject: Re: [PATCH 04/19] sched, numa, mm: Describe the NUMA scheduling
 problem formally
From: abhishek agarwal <abhigem.126@gmail.com>
Content-Type: multipart/alternative; boundary=f46d04339c96b7a92704cf4ba0b1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Hugh Dickins <hughd@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Mike Galbraith <efault@gmx.de>

--f46d04339c96b7a92704cf4ba0b1
Content-Type: text/plain; charset=ISO-8859-1

as per 4) move towards where "most" memory. If we have a large shared
memory than private memnory. Why not we just move the process towrds the
memory.. instead of the memory moving towards the node. This will i guess
be less cumbersome, then moving all the shared memory

On Fri, Nov 16, 2012 at 9:55 PM, Ingo Molnar <mingo@kernel.org> wrote:

> +Since per 2b our 's_i,k' and 'p_i' require at least two scans to
> 'stabilize'
> +and show representative numbers, we should limit node-migration to not be
> +faster than this.
>

--f46d04339c96b7a92704cf4ba0b1
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div class=3D"gmail_extra">as per 4) move towards where &quot;most&quot; me=
mory. If we have a large shared memory than private memnory. Why not we jus=
t move the process towrds the memory.. instead of the memory moving towards=
 the node. This will i guess be less cumbersome, then moving all the shared=
 memory<br>
<br><div class=3D"gmail_quote">On Fri, Nov 16, 2012 at 9:55 PM, Ingo Molnar=
 <span dir=3D"ltr">&lt;<a href=3D"mailto:mingo@kernel.org" target=3D"_blank=
">mingo@kernel.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quot=
e" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<div id=3D":2bn">+Since per 2b our &#39;s_i,k&#39; and &#39;p_i&#39; requir=
e at least two scans to &#39;stabilize&#39;<br>
+and show representative numbers, we should limit node-migration to not be<=
br>
+faster than this.</div></blockquote></div><br></div>

--f46d04339c96b7a92704cf4ba0b1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
