Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 118102802DE
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 06:20:02 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so11709128wic.1
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 03:20:01 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id o3si1626390wix.62.2015.07.16.03.20.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Jul 2015 03:20:00 -0700 (PDT)
Message-ID: <55A78548.1070603@arm.com>
Date: Thu, 16 Jul 2015 11:19:52 +0100
From: Vladimir Murzin <vladimir.murzin@arm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/3] memtest: cleanup log messages
References: <1436863249-1219-1-git-send-email-vladimir.murzin@arm.com> <1436863249-1219-3-git-send-email-vladimir.murzin@arm.com> <alpine.DEB.2.10.1507151655440.9230@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1507151655440.9230@chino.kir.corp.google.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "leon@leon.nu" <leon@leon.nu>

On 16/07/15 00:56, David Rientjes wrote:
> On Tue, 14 Jul 2015, Vladimir Murzin wrote:
>=20
>> - prefer pr_info(...  to printk(KERN_INFO ...
>> - use %pa for phys_addr_t
>> - use cpu_to_be64 while printing pattern in reserve_bad_mem()
>>
>> Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
>=20
> Acked-by: David Rientjes <rientjes@google.com>
>=20
> Not sure why you changed the whitespace in reserve_bad_mem() though.
>=20
>=20

I was changed by accident, thanks for pointing it out!

Andrew, could you apply the following fixup, please?

---8<---
diff --git a/mm/memtest.c b/mm/memtest.c
index 332facd..4b4f36b 100644
--- a/mm/memtest.c
+++ b/mm/memtest.c
@@ -26,7 +26,7 @@ static u64 patterns[] __initdata =3D {

 static void __init reserve_bad_mem(u64 pattern, phys_addr_t start_bad,
phys_addr_t end_bad)
 {
-=09pr_info("%016llx bad mem addr %pa - %pa reserved\n",
+=09pr_info("  %016llx bad mem addr %pa - %pa reserved\n",
 =09=09cpu_to_be64(pattern), &start_bad, &end_bad);
 =09memblock_reserve(start_bad, end_bad - start_bad);
 }
--->8---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
