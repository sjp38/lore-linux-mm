Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 317276B0074
	for <linux-mm@kvack.org>; Sun, 16 Nov 2014 19:15:46 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id k15so2379270qaq.38
        for <linux-mm@kvack.org>; Sun, 16 Nov 2014 16:15:45 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id j6si44914706qaz.30.2014.11.16.16.15.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 16 Nov 2014 16:15:35 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/3] hugetlb: fix hugepages= entry in
 kernel-parameters.txt
Date: Mon, 17 Nov 2014 00:11:17 +0000
Message-ID: <20141117001154.GA4667@hori1.linux.bs1.fc.nec.co.jp>
References: <1415831593-9020-1-git-send-email-lcapitulino@redhat.com>
 <1415831593-9020-2-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1415831593-9020-2-git-send-email-lcapitulino@redhat.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <F0F1F8460A9A9F48AE17EA8680997B13@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "rientjes@google.com" <rientjes@google.com>, "riel@redhat.com" <riel@redhat.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "davidlohr@hp.com" <davidlohr@hp.com>

On Wed, Nov 12, 2014 at 05:33:11PM -0500, Luiz Capitulino wrote:
> The hugepages=3D entry in kernel-parameters.txt states that
> 1GB pages can only be allocated at boot time and not
> freed afterwards. This is not true since commit
> 944d9fec8d7aee, at least for x86_64.
>=20
> Instead of adding arch-specifc observations to the
> hugepages=3D entry, this commit just drops the out of date
> information. Further information about arch-specific
> support and available features can be obtained in the
> hugetlb documentation.
>=20
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  Documentation/kernel-parameters.txt | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>=20
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-p=
arameters.txt
> index 479f332..d919af0 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -1228,9 +1228,7 @@ bytes respectively. Such letter suffixes can also b=
e entirely omitted.
>  			multiple times interleaved with hugepages=3D to reserve
>  			huge pages of different sizes. Valid pages sizes on
>  			x86-64 are 2M (when the CPU supports "pse") and 1G
> -			(when the CPU supports the "pdpe1gb" cpuinfo flag)
> -			Note that 1GB pages can only be allocated at boot time
> -			using hugepages=3D and not freed afterwards.
> +			(when the CPU supports the "pdpe1gb" cpuinfo flag).
> =20
>  	hvc_iucv=3D	[S390] Number of z/VM IUCV hypervisor console (HVC)
>  			       terminal devices. Valid values: 0..8
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
