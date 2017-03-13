Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id BD1B96B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 16:55:39 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id w185so55676703ita.5
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 13:55:39 -0700 (PDT)
Received: from gate2.alliedtelesis.co.nz (gate2.alliedtelesis.co.nz. [202.36.163.20])
        by mx.google.com with ESMTPS id v88si12485685pfi.174.2017.03.13.13.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 13:55:38 -0700 (PDT)
From: Chris Packham <Chris.Packham@alliedtelesis.co.nz>
Subject: Re: [PATCH] mm, gup: fix typo in gup_p4d_range()
Date: Mon, 13 Mar 2017 20:55:33 +0000
Message-ID: <e020448c790946c2b2edc36c92a8814d@svr-chch-ex1.atlnz.lc>
References: <20170313052213.11411-1-kirill.shutemov@linux.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 13/03/17 18:22, Kirill A. Shutemov wrote:=0A=
> gup_p4d_range() should call gup_pud_range(), not itself.=0A=
>=0A=
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>=0A=
> Reported-by: Chris Packham <chris.packham@alliedtelesis.co.nz>=0A=
> Fixes: c2febafc6773 ("mm: convert generic code to 5-level paging")=0A=
> ---=0A=
>  mm/gup.c | 2 +-=0A=
>  1 file changed, 1 insertion(+), 1 deletion(-)=0A=
>=0A=
> diff --git a/mm/gup.c b/mm/gup.c=0A=
> index c74bad1bf6e8..04aa405350dc 100644=0A=
> --- a/mm/gup.c=0A=
> +++ b/mm/gup.c=0A=
> @@ -1455,7 +1455,7 @@ static int gup_p4d_range(pgd_t pgd, unsigned long a=
ddr, unsigned long end,=0A=
>  			if (!gup_huge_pd(__hugepd(p4d_val(p4d)), addr,=0A=
>  					 P4D_SHIFT, next, write, pages, nr))=0A=
>  				return 0;=0A=
> -		} else if (!gup_p4d_range(p4d, addr, next, write, pages, nr))=0A=
> +		} else if (!gup_pud_range(p4d, addr, next, write, pages, nr))=0A=
>  			return 0;=0A=
>  	} while (p4dp++, addr =3D next, addr !=3D end);=0A=
=0A=
Fixes the build issue for me. Thanks.=0A=
=0A=
=0A=
=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
