Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id A96906B0038
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 17:12:04 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id wn1so9818994obc.18
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 14:12:04 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id qs7si19508959oeb.68.2014.11.03.14.12.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 14:12:03 -0800 (PST)
From: "Elliott, Robert (Server Storage)" <Elliott@hp.com>
Subject: RE: [PATCH v4 4/7] x86, mm, pat: Add pgprot_writethrough() for WT
Date: Mon, 3 Nov 2014 22:10:39 +0000
Message-ID: <94D0CD8314A33A4D9D801C0FE68B4029593578ED@G9W0745.americas.hpqcorp.net>
References: <1414450545-14028-1-git-send-email-toshi.kani@hp.com>
 <1414450545-14028-5-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1414450545-14028-5-git-send-email-toshi.kani@hp.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshimitsu" <toshi.kani@hp.com>, "hpa@zytor.com" <hpa@zytor.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "arnd@arndb.de" <arnd@arndb.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jgross@suse.com" <jgross@suse.com>, "stefan.bader@canonical.com" <stefan.bader@canonical.com>, "luto@amacapital.net" <luto@amacapital.net>, "hmh@hmh.eng.br" <hmh@hmh.eng.br>, "yigal@plexistor.com" <yigal@plexistor.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>



> -----Original Message-----
> From: linux-kernel-owner@vger.kernel.org [mailto:linux-kernel-
> owner@vger.kernel.org] On Behalf Of Kani, Toshimitsu
> Sent: Monday, 27 October, 2014 5:56 PM
> To: hpa@zytor.com; tglx@linutronix.de; mingo@redhat.com; akpm@linux-
> foundation.org; arnd@arndb.de
> Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org;
> jgross@suse.com; stefan.bader@canonical.com; luto@amacapital.net;
> hmh@hmh.eng.br; yigal@plexistor.com; konrad.wilk@oracle.com; Kani,
> Toshimitsu
> Subject: [PATCH v4 4/7] x86, mm, pat: Add pgprot_writethrough() for
> WT
>=20
> This patch adds pgprot_writethrough() for setting WT to a given
> pgprot_t.
>=20
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
...
> diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
> index a214f5a..a0264d3 100644
> --- a/arch/x86/mm/pat.c
> +++ b/arch/x86/mm/pat.c
> @@ -896,6 +896,16 @@ pgprot_t pgprot_writecombine(pgprot_t prot)
>  }
>  EXPORT_SYMBOL_GPL(pgprot_writecombine);
>=20
> +pgprot_t pgprot_writethrough(pgprot_t prot)
> +{
> +	if (pat_enabled)
> +		return __pgprot(pgprot_val(prot) |
> +				cachemode2protval(_PAGE_CACHE_MODE_WT));
> +	else
> +		return pgprot_noncached(prot);
> +}
> +EXPORT_SYMBOL_GPL(pgprot_writethrough);
...

Would you be willing to use EXPORT_SYMBOL for the new=20
pgprot_writethrough function to provide more flexibility
for modules to utilize the new feature?  In x86/mm, 18 of 60
current exports are GPL and 42 are not GPL.

---
Rob Elliott    HP Server Storage


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
