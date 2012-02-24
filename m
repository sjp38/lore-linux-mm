Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id A3F906B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 13:23:47 -0500 (EST)
Received: by qadz32 with SMTP id z32so473932qad.14
        for <linux-mm@kvack.org>; Fri, 24 Feb 2012 10:23:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201202241112.46337.vapier@gentoo.org>
References: <20120222150010.c784b29b.akpm@linux-foundation.org>
	<201202231847.55733.vapier@gentoo.org>
	<CAAHN_R0ihoA6K8w53ToRD1xew9NWk-bJAZ=U0+hgRV3=0FpVDg@mail.gmail.com>
	<201202241112.46337.vapier@gentoo.org>
Date: Fri, 24 Feb 2012 23:53:38 +0530
Message-ID: <CAAHN_R1Viv5GpJfbvc71OyNG7CdFWei7-3XPTap47MM2e8uEsg@mail.gmail.com>
Subject: Re: [PATCH] Mark thread stack correctly in proc/<pid>/maps
From: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Frysinger <vapier@gentoo.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Jamie Lokier <jamie@shareable.org>

On Fri, Feb 24, 2012 at 9:42 PM, Mike Frysinger <vapier@gentoo.org> wrote:
>> I like the idea of marking all stack vmas with their task ids but it
>> will most likely break procps.
>
> how ?

I don't know yet, since I haven't looked at the procps code. I intend
to do that once the patch is stable. But I imagine it would look for
"[stack]" or something similar in the output. It ought to be easy
enough to change I guess.

>> Besides, I think it could be done within procps with this change rather =
than
>> having the kernel do it.
>
> how exactly is procps supposed to figure this out ? =A0/proc/<pid>/maps s=
hows the
> pid's main stack, as does /proc/<pid>/tid/*/maps.

Since the maps are essentially the same, it would require pmap for
example, to read through the PID/maps as well as TID/maps and
associate them. I understand now that this may be a little racy.

I'll include thread ids and see how procps copes with it.


--=20
Siddhesh Poyarekar
http://siddhesh.in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
