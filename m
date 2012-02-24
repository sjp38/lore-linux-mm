Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 3ECAF6B004D
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 08:05:42 -0500 (EST)
Received: by ghrr18 with SMTP id r18so1290360ghr.14
        for <linux-mm@kvack.org>; Fri, 24 Feb 2012 05:05:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120223122215.d280b090.akpm@linux-foundation.org>
References: <20120222150010.c784b29b.akpm@linux-foundation.org>
	<1329969811-3997-1-git-send-email-siddhesh.poyarekar@gmail.com>
	<20120223122215.d280b090.akpm@linux-foundation.org>
Date: Fri, 24 Feb 2012 18:35:40 +0530
Message-ID: <CAAHN_R3zjh-xQ9yW57JhQ=AiJG+DV6D_ppveh3BvUYy8NWU3Lg@mail.gmail.com>
Subject: Re: [PATCH] Mark thread stack correctly in proc/<pid>/maps
From: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Jamie Lokier <jamie@shareable.org>, Mike Frysinger <vapier@gentoo.org>

On Fri, Feb 24, 2012 at 1:52 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> Looks OK to me, thanks. =A0I doubt if those interface changes will cause
> significant disruption.
>

I just found one breakage due to this patch: `cat /proc/self/maps`
does not always get the stack marked right. I think this is because it
gets the $esp a little to early, even before the vma is sent to its
randomized space. That is why /proc/self/smaps works just ok as it
always wins the race due to the sheer volume of data it prints.
Similarly numa_maps always fails since its write volume is lower than
maps. I'll try to fix this.

--=20
Siddhesh Poyarekar
http://siddhesh.in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
