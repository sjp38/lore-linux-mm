Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 262176B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 03:01:56 -0500 (EST)
Received: by yhoo22 with SMTP id o22so1924871yho.14
        for <linux-mm@kvack.org>; Fri, 03 Feb 2012 00:01:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAAHN_R0O7a+RX7BDfas3+vC+mnQpp0h3y4bBa1u4T-Jt=S9J_w@mail.gmail.com>
References: <20120116163106.GC7180@jl-vm1.vm.bytemark.co.uk>
 <1326776095-2629-1-git-send-email-siddhesh.poyarekar@gmail.com>
 <CAAHN_R2g9zaujw30+zLf91AGDHNqE6HDc8Z4yJbrzgJcJYFkXg@mail.gmail.com>
 <4F2B02BC.8010308@gmail.com> <CAAHN_R0O7a+RX7BDfas3+vC+mnQpp0h3y4bBa1u4T-Jt=S9J_w@mail.gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Fri, 3 Feb 2012 03:01:35 -0500
Message-ID: <CAHGf_=qA6EFue2-mNUg9udWV4xSx86XQsnyGV07hfZOUx6_egw@mail.gmail.com>
Subject: Re: [RESEND][PATCH] Mark thread stack correctly in proc/<pid>/maps
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Cc: Jamie Lokier <jamie@shareable.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man@vger.kernel.org

> Right now MAP_STACK does not mean anything since it is ignored. The
> intention of this behaviour change is to make MAP_STACK mean that the
> map is going to be used as a stack and hence, set it up like a stack
> ought to be. I could not really think of a valid case for fixed size
> stacks; it looks like a limitation in the pthread implementation in
> glibc rather than a feature. So this patch will actually result in
> uniform behaviour across threads when it comes to stacks.
>
> This does change vm accounting since thread stacks were earlier
> accounted as anon memory.

The fact is, now process stack and pthread stack clearly behave
different dance. libc don't expect pthread stack grow automatically.
So, your patch will break userland. Just only change display thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
