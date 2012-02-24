Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 1EDE36B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 00:47:49 -0500 (EST)
Received: by qadz32 with SMTP id z32so117317qad.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 21:47:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201202231847.55733.vapier@gentoo.org>
References: <20120222150010.c784b29b.akpm@linux-foundation.org>
	<1329969811-3997-1-git-send-email-siddhesh.poyarekar@gmail.com>
	<201202231847.55733.vapier@gentoo.org>
Date: Fri, 24 Feb 2012 11:17:48 +0530
Message-ID: <CAAHN_R0ihoA6K8w53ToRD1xew9NWk-bJAZ=U0+hgRV3=0FpVDg@mail.gmail.com>
Subject: Re: [PATCH] Mark thread stack correctly in proc/<pid>/maps
From: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Frysinger <vapier@gentoo.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Jamie Lokier <jamie@shareable.org>

On Fri, Feb 24, 2012 at 5:17 AM, Mike Frysinger <vapier@gentoo.org> wrote:
> i don't suppose we could have it say "[tid stack]" rather than "[stack]" =
? =A0or
> perhaps even "[stack tid:%u]" with replacing %u with the tid ?

Why do we need to differentiate a thread stack from a process stack?
If someone really wants to know, the main stack is the last one since
it doesn't look like mmap allocates anything above the stack right
now.

I like the idea of marking all stack vmas with their task ids but it
will most likely break procps. Besides, I think it could be done
within procps with this change rather than having the kernel do it.

--=20
Siddhesh Poyarekar
http://siddhesh.in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
