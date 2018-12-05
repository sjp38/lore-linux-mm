Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07EF16B7501
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 10:30:00 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id v7so8253720wme.9
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 07:29:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x137sor9350102wmf.24.2018.12.05.07.29.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 07:29:58 -0800 (PST)
Reply-To: monstr@monstr.eu
Subject: Re: [PATCH v2 2/6] microblaze: prefer memblock API returning virtual
 address
References: <1543852035-26634-1-git-send-email-rppt@linux.ibm.com>
 <1543852035-26634-3-git-send-email-rppt@linux.ibm.com>
From: Michal Simek <monstr@monstr.eu>
Message-ID: <0a5e0aef-15fd-2d0c-765c-e7ba60219b00@monstr.eu>
Date: Wed, 5 Dec 2018 16:29:40 +0100
MIME-Version: 1.0
In-Reply-To: <1543852035-26634-3-git-send-email-rppt@linux.ibm.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="p80uXp4MQpFTW9kBmtIO081Y5oGpJXXIR"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, Michal Simek <michal.simek@xilinx.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--p80uXp4MQpFTW9kBmtIO081Y5oGpJXXIR
Content-Type: multipart/mixed; boundary="qysf5netJxUn4CkAZbDPuVrHjaMDiAo4f";
 protected-headers="v1"
From: Michal Simek <monstr@monstr.eu>
Reply-To: monstr@monstr.eu
To: Mike Rapoport <rppt@linux.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>,
 Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>,
 Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>,
 Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>,
 Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>,
 Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>,
 Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>,
 linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org,
 sparclinux@vger.kernel.org, Michal Simek <michal.simek@xilinx.com>
Message-ID: <0a5e0aef-15fd-2d0c-765c-e7ba60219b00@monstr.eu>
Subject: Re: [PATCH v2 2/6] microblaze: prefer memblock API returning virtual
 address
References: <1543852035-26634-1-git-send-email-rppt@linux.ibm.com>
 <1543852035-26634-3-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1543852035-26634-3-git-send-email-rppt@linux.ibm.com>

--qysf5netJxUn4CkAZbDPuVrHjaMDiAo4f
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 03. 12. 18 16:47, Mike Rapoport wrote:
> Rather than use the memblock_alloc_base that returns a physical address=
 and
> then convert this address to the virtual one, use appropriate memblock
> function that returns a virtual address.
>=20
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/microblaze/mm/init.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>=20
> diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
> index b17fd8a..44f4b89 100644
> --- a/arch/microblaze/mm/init.c
> +++ b/arch/microblaze/mm/init.c
> @@ -363,8 +363,9 @@ void __init *early_get_page(void)
>  	 * Mem start + kernel_tlb -> here is limit
>  	 * because of mem mapping from head.S
>  	 */
> -	return __va(memblock_alloc_base(PAGE_SIZE, PAGE_SIZE,
> -				memory_start + kernel_tlb));
> +	return memblock_alloc_try_nid_raw(PAGE_SIZE, PAGE_SIZE,
> +				MEMBLOCK_LOW_LIMIT, memory_start + kernel_tlb,
> +				NUMA_NO_NODE);
>  }
> =20
>  #endif /* CONFIG_MMU */
>=20

I can't see any issue with functionality when this patch is applied.
If you want me to take this via my tree please let me know.
Otherwise:

Tested-by: Michal Simek <michal.simek@xilinx.com>

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Xilinx Microblaze
Maintainer of Linux kernel - Xilinx Zynq ARM and ZynqMP ARM64 SoCs
U-Boot custodian - Xilinx Microblaze/Zynq/ZynqMP/Versal SoCs



--qysf5netJxUn4CkAZbDPuVrHjaMDiAo4f--

--p80uXp4MQpFTW9kBmtIO081Y5oGpJXXIR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEARECAAYFAlwH7ugACgkQykllyylKDCF+oQCcD3h8FTgH3lqEuM6g3LYVVKdA
5FUAn2kZEag4xhKtRwOtFFVaEnckXAmY
=WdzP
-----END PGP SIGNATURE-----

--p80uXp4MQpFTW9kBmtIO081Y5oGpJXXIR--
