Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8DBD76B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 04:38:13 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id x49so17730503qtc.7
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 01:38:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p88si47284894qtd.154.2017.01.05.01.38.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 01:38:12 -0800 (PST)
Subject: Re: [RFC PATCH v3] sparc64: Add support for Application Data
 Integrity (ADI)
References: <1483569999-13543-1-git-send-email-khalid.aziz@oracle.com>
From: Jerome Marchand <jmarchan@redhat.com>
Message-ID: <fc6696de-34d7-e4ce-2b39-f788ba22843e@redhat.com>
Date: Thu, 5 Jan 2017 10:37:54 +0100
MIME-Version: 1.0
In-Reply-To: <1483569999-13543-1-git-send-email-khalid.aziz@oracle.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="sohvc9WI75EfSsNXpXQdmT2AlG3UVldN7"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org
Cc: hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, dave.hansen@linux.intel.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--sohvc9WI75EfSsNXpXQdmT2AlG3UVldN7
Content-Type: multipart/mixed; boundary="AwKJ5KgT36TUmAJ2vEHPPTerIT0EXBbgB";
 protected-headers="v1"
From: Jerome Marchand <jmarchan@redhat.com>
To: Khalid Aziz <khalid.aziz@oracle.com>, davem@davemloft.net,
 corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org
Cc: hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com,
 chris.hyser@oracle.com, tushar.n.dave@oracle.com,
 sowmini.varadhan@oracle.com, mike.kravetz@oracle.com,
 adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com,
 kirill.shutemov@linux.intel.com, keescook@chromium.org,
 allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com,
 joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com,
 paul.gortmaker@windriver.com, mhocko@suse.com, dave.hansen@linux.intel.com,
 lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz,
 tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com,
 iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com,
 hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org,
 linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org,
 linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
 Khalid Aziz <khalid@gonehiking.org>
Message-ID: <fc6696de-34d7-e4ce-2b39-f788ba22843e@redhat.com>
Subject: Re: [RFC PATCH v3] sparc64: Add support for Application Data
 Integrity (ADI)
References: <1483569999-13543-1-git-send-email-khalid.aziz@oracle.com>
In-Reply-To: <1483569999-13543-1-git-send-email-khalid.aziz@oracle.com>

--AwKJ5KgT36TUmAJ2vEHPPTerIT0EXBbgB
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/04/2017 11:46 PM, Khalid Aziz wrote:
> ADI is a new feature supported on sparc M7 and newer processors to allo=
w
> hardware to catch rogue accesses to memory. ADI is supported for data
> fetches only and not instruction fetches. An app can enable ADI on its
> data pages, set version tags on them and use versioned addresses to
> access the data pages. Upper bits of the address contain the version
> tag. On M7 processors, upper four bits (bits 63-60) contain the version=

> tag. If a rogue app attempts to access ADI enabled data pages, its
> access is blocked and processor generates an exception.
>=20
> This patch extends mprotect to enable ADI (TSTATE.mcde), enable/disable=

> MCD (Memory Corruption Detection) on selected memory ranges, enable
> TTE.mcd in PTEs, return ADI parameters to userspace and save/restore AD=
I
> version tags on page swap out/in.  It also adds handlers for all traps
> related to MCD. ADI is not enabled by default for any task. A task must=

> explicitly enable ADI on a memory range and set version tag for ADI to
> be effective for the task.
>=20
> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
> Cc: Khalid Aziz <khalid@gonehiking.org>
> ---
> v2:
> 	- Fixed a build error
>=20
> v3:
> 	- Removed CONFIG_SPARC_ADI
> 	- Replaced prctl commands with mprotect
> 	- Added auxiliary vectors for ADI parameters
> 	- Enabled ADI for swappable pages
>=20
>  Documentation/sparc/adi.txt             | 239 ++++++++++++++++++++++++=
++++++++
>  arch/sparc/include/asm/adi.h            |   6 +
>  arch/sparc/include/asm/adi_64.h         |  46 ++++++
>  arch/sparc/include/asm/elf_64.h         |   8 ++
>  arch/sparc/include/asm/hugetlb.h        |  13 ++
>  arch/sparc/include/asm/hypervisor.h     |   2 +
>  arch/sparc/include/asm/mman.h           |  40 +++++-
>  arch/sparc/include/asm/mmu_64.h         |   2 +
>  arch/sparc/include/asm/mmu_context_64.h |  32 +++++
>  arch/sparc/include/asm/pgtable_64.h     |  97 ++++++++++++-
>  arch/sparc/include/asm/ttable.h         |  10 ++
>  arch/sparc/include/asm/uaccess_64.h     | 120 +++++++++++++++-
>  arch/sparc/include/uapi/asm/asi.h       |   5 +
>  arch/sparc/include/uapi/asm/auxvec.h    |   8 ++
>  arch/sparc/include/uapi/asm/mman.h      |   2 +
>  arch/sparc/include/uapi/asm/pstate.h    |  10 ++
>  arch/sparc/kernel/Makefile              |   1 +
>  arch/sparc/kernel/adi_64.c              |  93 +++++++++++++
>  arch/sparc/kernel/entry.h               |   3 +
>  arch/sparc/kernel/head_64.S             |   1 +
>  arch/sparc/kernel/mdesc.c               |   4 +
>  arch/sparc/kernel/process_64.c          |  21 +++
>  arch/sparc/kernel/sun4v_mcd.S           |  16 +++
>  arch/sparc/kernel/traps_64.c            | 142 ++++++++++++++++++-
>  arch/sparc/kernel/ttable_64.S           |   6 +-
>  arch/sparc/mm/gup.c                     |  37 +++++
>  arch/sparc/mm/tlb.c                     |  28 ++++
>  arch/x86/kernel/signal_compat.c         |   2 +-
>  include/asm-generic/pgtable.h           |   5 +
>  include/linux/mm.h                      |   2 +
>  include/uapi/asm-generic/siginfo.h      |   5 +-
>  mm/memory.c                             |   2 +-
>  mm/rmap.c                               |   4 +-

I haven't actually reviewed the code and looked at why you need
set_swp_pte_at() function, but the code that add the generic version of
this function need to be separated from the rest of the patch. Also,
given the size of this patch, I suspect the rest also need to be broken
into more patches.

Jerome


--AwKJ5KgT36TUmAJ2vEHPPTerIT0EXBbgB--

--sohvc9WI75EfSsNXpXQdmT2AlG3UVldN7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJYbhPyAAoJEHTzHJCtsuoCRbsH/2g2oUJ5VzNQAlk9RV46wAJa
pJZwWhC7GSVKmbBF5zA2FvPHd4zIoWwnVQuKXdTDTKSX7o/Thm0QqqZOTm0Y1YKB
qAviSK/cgvothZOlDozE5bjHkHk6PLpzBYiZfdOkFfFSljleKWXcVjNfkNT2RaHq
G6SYcUkwKA2xGJ+TAeWAAlh7QOO7brI51ZIhd7QgMK8weKWzuMnlesumnYHEBJP5
mcT/K0TCFzplC7kHzhXZPkMa7i5zJQcdidxFOya+61VsF+NWX/1Cz6T2o3ZABRLW
192NW6KYkLAkT3eHWNB1zI4Ukg9dBL6it3SzJ2KSVlt8/rT2B//JKjn7rfeaSRI=
=lvlT
-----END PGP SIGNATURE-----

--sohvc9WI75EfSsNXpXQdmT2AlG3UVldN7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
