Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 439836B0083
	for <linux-mm@kvack.org>; Sun, 16 Nov 2014 19:16:19 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id h15so2472362igd.14
        for <linux-mm@kvack.org>; Sun, 16 Nov 2014 16:16:18 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id h187si52250391ioe.107.2014.11.16.16.16.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 16 Nov 2014 16:16:16 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/3] hugetlb: hugetlb_register_all_nodes(): add __init
 marker
Date: Mon, 17 Nov 2014 00:12:24 +0000
Message-ID: <20141117001301.GC4667@hori1.linux.bs1.fc.nec.co.jp>
References: <1415831593-9020-1-git-send-email-lcapitulino@redhat.com>
 <1415831593-9020-4-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1415831593-9020-4-git-send-email-lcapitulino@redhat.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <D9064B7E273C684ABEA1AD5EE820A2FC@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "rientjes@google.com" <rientjes@google.com>, "riel@redhat.com" <riel@redhat.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "davidlohr@hp.com" <davidlohr@hp.com>

On Wed, Nov 12, 2014 at 05:33:13PM -0500, Luiz Capitulino wrote:
> This function is only called during initialization.
>=20
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/hugetlb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index a10fd57..9785546 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2083,7 +2083,7 @@ static void hugetlb_register_node(struct node *node=
)
>   * devices of nodes that have memory.  All on-line nodes should have
>   * registered their associated device by this time.
>   */
> -static void hugetlb_register_all_nodes(void)
> +static void __init hugetlb_register_all_nodes(void)
>  {
>  	int nid;
> =20
> --=20
> 1.9.3
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
