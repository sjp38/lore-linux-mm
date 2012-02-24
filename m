Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 30C0A6B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 19:50:06 -0500 (EST)
Received: by yenl5 with SMTP id l5so1112024yen.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 16:50:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHGf_=oi8_s0Bxn4qSD7S_FBSgp29BPXor4hCf5-kekGnf3qEw@mail.gmail.com>
References: <4F32B776.6070007@gmail.com> <1328972596-4142-1-git-send-email-siddhesh.poyarekar@gmail.com>
 <CAHGf_=oi8_s0Bxn4qSD7S_FBSgp29BPXor4hCf5-kekGnf3qEw@mail.gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 23 Feb 2012 19:49:45 -0500
Message-ID: <CAHGf_=q7epQdxRMpQGhZ+734dZRPbM+wdAP74NwJrKLvkxZKuQ@mail.gmail.com>
Subject: Re: [PATCH] Mark thread stack correctly in proc/<pid>/maps
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Jamie Lokier <jamie@shareable.org>, vapier@gentoo.org

2012/2/23 KOSAKI Motohiro <kosaki.motohiro@gmail.com>:
> Hi
>
> This version makes sense to me. and I verified this change don't break
> procps tools.

Sigh. No, I missed one thing. If application use
makecontext()/swapcontext() pair,
ESP is not reliable way to detect pthread stack. At that time the
stack is still marked
as anonymous memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
