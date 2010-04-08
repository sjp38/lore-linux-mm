Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E192A600373
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 02:49:14 -0400 (EDT)
Received: by pzk30 with SMTP id 30so1767948pzk.12
        for <linux-mm@kvack.org>; Wed, 07 Apr 2010 23:49:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <EAEEEBBE07F4F24C89FEF850CF8C77420142A21107@shzsmsx502.ccr.corp.intel.com>
References: <EAEEEBBE07F4F24C89FEF850CF8C77420142A21107@shzsmsx502.ccr.corp.intel.com>
Date: Thu, 8 Apr 2010 15:49:13 +0900
Message-ID: <z2s28c262361004072349xfb2ab477lc416d8d372f0a008@mail.gmail.com>
Subject: Re: [PATCH] race condition between __purge_vmap_area_lazy() and
	free_unmap_vmap_area_noflush()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Zhao, Leifu" <leifu.zhao@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 8, 2010 at 3:36 PM, Zhao, Leifu <leifu.zhao@intel.com> wrote:
> Hi all,
>
> I found a bug in 2.6.28 kernel and got the fix for it, see below bug desc=
ription, log information and the patch. As I know this bug still exists in =
at least 2.6.32 kernel. I am new in the kernel development process, can som=
eone tell me what should proceed next?
>

Good catch!.

But it was already fixed.

https://patchwork.kernel.org/patch/89783/

Thanks.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
