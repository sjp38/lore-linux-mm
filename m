Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9AFCD6B0038
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 04:42:53 -0400 (EDT)
Received: by qcgx3 with SMTP id x3so62031382qcg.3
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 01:42:53 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [146.101.78.143])
        by mx.google.com with ESMTP id n40si2689432qkh.89.2015.04.02.01.42.52
        for <linux-mm@kvack.org>;
        Thu, 02 Apr 2015 01:42:52 -0700 (PDT)
Message-ID: <551D0101.6000301@arm.com>
Date: Thu, 02 Apr 2015 09:42:41 +0100
From: Vladimir Murzin <vladimir.murzin@arm.com>
MIME-Version: 1.0
Subject: Re: mmotm 2015-04-01-14-54 uploaded
References: <551c6943.H+vcYDrtw2kStb+B%akpm@linux-foundation.org>
In-Reply-To: <551c6943.H+vcYDrtw2kStb+B%akpm@linux-foundation.org>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, "mhocko@suse.cz" <mhocko@suse.cz>

On 01/04/15 22:55, akpm@linux-foundation.org wrote:
> * mm-move-memtest-under-mm.patch
> * mm-move-memtest-under-mm-fix.patch

It was noticed by Paul Bolle (and his clever bot) that patch above
simply disables MEMTEST altogether [1]. Could you fold fix for that, please=
?

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index ea369dd..cd6d74b 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1810,7 +1810,7 @@ config TEST_UDELAY

 config MEMTEST
 =09bool "Memtest"
-=09depends on MEMBLOCK
+=09depends on HAVE_MEMBLOCK
 =09---help---
 =09  This option adds a kernel parameter 'memtest', which allows memtest
 =09  to be set.
--

[1] https://lkml.org/lkml/2015/3/20/119

Thanks
Vladimir

> * memtest-use-phys_addr_t-for-physical-addresses.patch
> * arm64-add-support-for-memtest.patch
> * arm-add-support-for-memtest.patch
> * kconfig-memtest-update-number-of-test-patterns-up-to-17.patch
> * documentation-update-arch-list-in-the-memtest-entry.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
