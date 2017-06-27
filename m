Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D716C6B0279
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 22:13:39 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id o62so16294381pga.0
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 19:13:39 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id u185si1043428pgd.119.2017.06.26.19.13.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 19:13:39 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id z6so2629455pfk.3
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 19:13:38 -0700 (PDT)
Date: Tue, 27 Jun 2017 10:13:35 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC PATCH 0/4] mm/hotplug: make hotplug memory_block alligned
Message-ID: <20170627021335.GA62718@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
 <20170626074635.GB11534@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="DocE+STaALJfprDB"
Content-Disposition: inline
In-Reply-To: <20170626074635.GB11534@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 26, 2017 at 09:46:35AM +0200, Michal Hocko wrote:
>On Sun 25-06-17 10:52:23, Wei Yang wrote:
>> Michal & all
>>=20
>> Previously we found the hotplug range is mem_section aligned instead of
>> memory_block.
>>=20
>> Here is several draft patches to fix that. To make sure I am getting your
>> point correctly, I post it here before further investigation.
>
>This description doesn't explain what the problem is and why do we want
>to fix it. Before diving into the code and review changes it would help
>a lot to give a short introduction and explain your intention and your
>assumptions you base your changes on.
>
>So please start with a highlevel description first.
>

Here is the high level description in my mind, glad to see your comment.


The minimum unit of memory hotplug is memory_block instead of mem_section.
While in current implementation, we see several concept misunderstanding.

For example:
1. The alignment check is based on mem_section instead of memory_block
2. Online memory range on section base instead of memory_block base

Even memory_block and mem_section are close related, they are two concepts.=
 It
is possible to initialize and register them respectively.

For example:
1. In __add_section(), it tries to register these two in one place.

This patch generally does the following:
1. Aligned the range with memory_block
2. Online rage with memory_block base
3. Split the registration of memory_block and mem_section



--=20
Wei Yang
Help you, Help me

--DocE+STaALJfprDB
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZUb9PAAoJEKcLNpZP5cTduEkP/i5QNL6RogFS/sxW/kmiba+x
KRd45pBAtnw2hi9qMeSkuNbo8RxRIP2LYY95b2GFPmHJVdezkuPp9plyiDmVPrNQ
GUZ0CxuSDvP0m/RSxbExeH4WOHsViZZ1YNDFSv3Sqvq6ROv9wrzkEq92ZM+vIBsB
nj82aHGXzBMfl9J+kzkE42B3gFa/2aM+fRPdLndKL80nvEP3JQk/DNYPrKOz+Ou0
9YEF/zux8ZsGRKkOc6cyzZCy8STJjEpRhuAOc8hZukJ70zyuopXaRsI1sXU0daFa
IEfO9cq+dOsLIVCsvvuccP5ngVeJdG21XZFfLLINX99Lv5nbxYMKL7/SEogm2U+K
HL2suQyqtpfz4XI/PCuK3m5RIPshGF9RFogrwTe3WiMqmnR166s/EfKnZhPd25xx
HUuTXYy0ixCvFfkMkIADoBXtOTD8c+2GE0aYt29PF+7gBqgGpYpJaeap1dagxN55
uwnRQPsh6iAGBsbJPLdOatq+CUg74x2DzmrRIOJChHk/eKpHLtDljtLcAJc2bThy
Bn4bcDOTngv6aygJ1beY2SF0sQuM/irz+GNcqDNyBL2NBi59LD7drZ8ujNDN5xR4
prLlPvg4JOPw2CB3fxeLf0m0i26qEniA1Y3ObtYLPlzv2jISPrqonGCswJPULydh
EiDv6fG/kfN0lNGlEpgq
=Bfbt
-----END PGP SIGNATURE-----

--DocE+STaALJfprDB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
