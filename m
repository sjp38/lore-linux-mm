Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C4F056B0032
	for <linux-mm@kvack.org>; Sat,  5 Oct 2013 02:28:11 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so5057703pad.30
        for <linux-mm@kvack.org>; Fri, 04 Oct 2013 23:28:11 -0700 (PDT)
From: "Dilger, Andreas" <andreas.dilger@intel.com>
Subject: Re: [PATCH 10/26] lustre: Convert ll_get_user_pages() to use
 get_user_pages_fast()
Date: Sat, 5 Oct 2013 06:27:43 +0000
Message-ID: <CE750CA8.75301%andreas.dilger@intel.com>
In-Reply-To: <1380724087-13927-11-git-send-email-jack@suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <78094AFAA7D9084EB3F62453362B75D3@intel.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg Kroah-Hartman <greg@kroah.com>, Peng Tao <tao.peng@emc.com>, "hpdd-discuss@lists.01.org" <hpdd-discuss@lists.01.org>

On 2013/10/02 8:27 AM, "Jan Kara" <jack@suse.cz> wrote:
>CC: Greg Kroah-Hartman <greg@kroah.com>
>CC: Peng Tao <tao.peng@emc.com>
>CC: Andreas Dilger <andreas.dilger@intel.com>
>CC: hpdd-discuss@lists.01.org
>Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Andreas Dilger <andreas.dilger@intel.com>

>---
> drivers/staging/lustre/lustre/llite/rw26.c | 7 ++-----
> 1 file changed, 2 insertions(+), 5 deletions(-)
>
>diff --git a/drivers/staging/lustre/lustre/llite/rw26.c
>b/drivers/staging/lustre/lustre/llite/rw26.c
>index 96c29ad2fc8c..7e3e0967993b 100644
>--- a/drivers/staging/lustre/lustre/llite/rw26.c
>+++ b/drivers/staging/lustre/lustre/llite/rw26.c
>@@ -202,11 +202,8 @@ static inline int ll_get_user_pages(int rw, unsigned
>long user_addr,
>=20
> 	OBD_ALLOC_LARGE(*pages, *max_pages * sizeof(**pages));
> 	if (*pages) {
>-		down_read(&current->mm->mmap_sem);
>-		result =3D get_user_pages(current, current->mm, user_addr,
>-					*max_pages, (rw =3D=3D READ), 0, *pages,
>-					NULL);
>-		up_read(&current->mm->mmap_sem);
>+		result =3D get_user_pages_fast(user_addr, *max_pages,
>+					     (rw =3D=3D READ), *pages);
> 		if (unlikely(result <=3D 0))
> 			OBD_FREE_LARGE(*pages, *max_pages * sizeof(**pages));
> 	}


Cheers, Andreas
--=20
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
