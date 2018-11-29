Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 322336B52F4
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 09:10:08 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id o131-v6so1188501yba.17
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 06:10:08 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 144si1220343ywj.260.2018.11.29.06.10.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 06:10:06 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH] sysctl: clean up nr_pdflush_threads leftover
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181128152407.19062-1-aquini@redhat.com>
Date: Thu, 29 Nov 2018 07:09:56 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <867FB7CF-C7CC-454F-8845-5026FC3D5BEA@oracle.com>
References: <20181128152407.19062-1-aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, davem@davemloft.net, virgile@acceis.fr, linux-mm@kvack.org



> On Nov 28, 2018, at 8:24 AM, Rafael Aquini <aquini@redhat.com> wrote:
>=20
> nr_pdflush_threads has been long deprecated and
> removed, but a remnant of its glorious past is
> still around in CTL_VM names enum. This patch
> is a minor clean-up to that case.
>=20
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
> ---
> include/uapi/linux/sysctl.h | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/include/uapi/linux/sysctl.h b/include/uapi/linux/sysctl.h
> index d71013fffaf6..dad5a8f93343 100644
> --- a/include/uapi/linux/sysctl.h
> +++ b/include/uapi/linux/sysctl.h
> @@ -174,7 +174,7 @@ enum
> 	VM_DIRTY_RATIO=3D12,	/* dirty_ratio */
> 	VM_DIRTY_WB_CS=3D13,	/* dirty_writeback_centisecs */
> 	VM_DIRTY_EXPIRE_CS=3D14,	/* dirty_expire_centisecs */
> -	VM_NR_PDFLUSH_THREADS=3D15, /* nr_pdflush_threads */
> +	VM_UNUSED15=3D15,		/* was: int nr_pdflush_threads =
*/
> 	VM_OVERCOMMIT_RATIO=3D16, /* percent of RAM to allow overcommit =
in */
> 	VM_PAGEBUF=3D17,		/* struct: Control pagebuf =
parameters */
> 	VM_HUGETLB_PAGES=3D18,	/* int: Number of available Huge Pages =
*/
> --=20
> 2.17.2
>=20

Please reword the comment to add a colon after the word "int" to match =
earlier
comments in the enum:

+	VM_UNUSED15=3D15,		/* was: int: nr_pdflush_threads =
*/

Also, as long as you're changing this file, please fix the typo earlier =
in the
same enum:

-	VM_UNUSED2=3D2,		/* was; int: Linear or sqrt() swapout =
for hogs */
+	VM_UNUSED2=3D2,		/* was: int: Linear or sqrt() swapout =
for hogs */


Reviewed-by: William Kucharski <william.kucharski@oracle.com>=
