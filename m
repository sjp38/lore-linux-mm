Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 5CBF86B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 04:49:43 -0500 (EST)
Received: by ghrr18 with SMTP id r18so2052194ghr.14
        for <linux-mm@kvack.org>; Fri, 03 Feb 2012 01:49:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHGf_=qA6EFue2-mNUg9udWV4xSx86XQsnyGV07hfZOUx6_egw@mail.gmail.com>
References: <20120116163106.GC7180@jl-vm1.vm.bytemark.co.uk>
	<1326776095-2629-1-git-send-email-siddhesh.poyarekar@gmail.com>
	<CAAHN_R2g9zaujw30+zLf91AGDHNqE6HDc8Z4yJbrzgJcJYFkXg@mail.gmail.com>
	<4F2B02BC.8010308@gmail.com>
	<CAAHN_R0O7a+RX7BDfas3+vC+mnQpp0h3y4bBa1u4T-Jt=S9J_w@mail.gmail.com>
	<CAHGf_=qA6EFue2-mNUg9udWV4xSx86XQsnyGV07hfZOUx6_egw@mail.gmail.com>
Date: Fri, 3 Feb 2012 15:19:42 +0530
Message-ID: <CAAHN_R13iFpMQLPDM8y9gTjf+QdiO61LU_HVkUronrOBZRJvTA@mail.gmail.com>
Subject: Re: [RESEND][PATCH] Mark thread stack correctly in proc/<pid>/maps
From: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Jamie Lokier <jamie@shareable.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man@vger.kernel.org

On Fri, Feb 3, 2012 at 1:31 PM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
> The fact is, now process stack and pthread stack clearly behave
> different dance. libc don't expect pthread stack grow automatically.
> So, your patch will break userland. Just only change display thing.

Thanks for your feedback. This attempt was to unify this behaviours,
but I guess you're right; I need to check if glibc really has a
problem with this than assuming that it should not. I will check with
glibc maintainers on this and update here. Since this flag is
specifically for glibc, it should not affect other applications or
libraries.

The proc changes won't make sense without the change to mark thread
stacks unless we create yet another vm flag to reflect MAP_STACK in
the vma and then use that for both process and its threads. I'll
submit a patch with this (if acceptable of course) if glibc strictly
requires fixed sized stacks.

-- 
Siddhesh Poyarekar
http://siddhesh.in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
