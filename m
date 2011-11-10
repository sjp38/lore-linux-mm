Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 137826B002D
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 23:09:11 -0500 (EST)
Received: by vcbfo11 with SMTP id fo11so1263375vcb.14
        for <linux-mm@kvack.org>; Wed, 09 Nov 2011 20:09:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110412151116.B50D.A69D9226@jp.fujitsu.com>
References: <20110412151116.B50D.A69D9226@jp.fujitsu.com>
Date: Thu, 10 Nov 2011 12:09:08 +0800
Message-ID: <CAPQyPG7RrpV8DBV_Qcgr2at_r25_ngjy_84J2FqzRPGfA3PGDA@mail.gmail.com>
Subject: Re: mm: convert vma->vm_flags to 64bit
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Russell King <linux@arm.linux.org.uk>

Hi all,

Did this patch get merged at last, or on this way being merged, or
just dropped ?

Thanks,

Nai

On Tue, Apr 12, 2011 at 2:10 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>
> Benjamin, Hugh, I hope to add your S-O-B to this one because you are orig=
inal author.
> Can I do?
>
> Paul, Russell, This patch modifies arm and sh code a bit. I don't think
> they are risky change. but I'm really glad if you see it.
>
>
> Note: I confirmed x86, power and nommu-arm cross compiler build and
> I've got no warning/error.
>
>
>
> From d5a0d1c265e4caccb9ff5978c615f74019b65453 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Tue, 12 Apr 2011 14:00:42 +0900
> Subject: [PATCH] mm: convert vma->vm_flags to 64bit
>
> For years, powerpc people repeatedly request us to convert vm_flags
> to 64bit. Because now it has no room to store an addional powerpc
> specific flags.
>
> Here is previous discussion logs.
>
> =A0 =A0 =A0 =A0http://lkml.org/lkml/2009/10/1/202
> =A0 =A0 =A0 =A0http://lkml.org/lkml/2010/4/27/23
>
> But, unforunately they didn't get merged. This is 3rd trial.
> I've merged previous two posted patches and adapted it for
> latest tree.
>
> Of cource, this patch has no functional change.
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Dave Hansen <dave@linux.vnet.ibm.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
