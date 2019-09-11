Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BE09C49ED6
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 15:19:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B8C3206A5
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 15:19:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="P+MDd2FC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B8C3206A5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A649A6B027B; Wed, 11 Sep 2019 11:19:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A15EB6B027C; Wed, 11 Sep 2019 11:19:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 903CE6B027D; Wed, 11 Sep 2019 11:19:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0245.hostedemail.com [216.40.44.245])
	by kanga.kvack.org (Postfix) with ESMTP id 691EB6B027B
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 11:19:23 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 0BB64180AD7C3
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:19:23 +0000 (UTC)
X-FDA: 75922998606.10.joke57_17a815d68183f
X-HE-Tag: joke57_17a815d68183f
X-Filterd-Recvd-Size: 7207
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:19:22 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id 4so21153820qki.6
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 08:19:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=ZU9ZAjmx+sYl629AtpqCVueI4p9/wYdOG6Cg3kJEbbA=;
        b=P+MDd2FC4Tc061IIYYh+fnI7tLbvNzMEPGfTHDCLdu2V2A1iaUfoGPOyKo1ZcCp2tM
         vDlQak9qwdFXMTF01sdF9NaWHYqP1Z/eiHE2pYAG4FrrFsTi2bCatToJIx7hX7STqCMC
         e85SYvrxtgXBNTGH/ehZFacewWsbP3akXbDmXt6EUDu/lp7mYlWlv1TyYoYV+BNcPW4F
         TyQwa7/S4+maJvqyBvr3GUHM1ID8EHp3pq+TdjfeKrIVUgE8Tw3I5En61hXz9Gu0JACc
         WwgWy0IYjBit1gDB8Hqa1cVn0uxte+0fby7CvbIJdCpE5oqr9900yYQW4eRFZ2W0lIU6
         oFtg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=ZU9ZAjmx+sYl629AtpqCVueI4p9/wYdOG6Cg3kJEbbA=;
        b=Wo9OEXn0mknS9T09Mwd8bej2B2pvk1d2peVK3XLUvXlTTWqDGJMSFOa0mpjqLAiWuK
         z+HhzbiLffBDpktb5rcldbkCnhVdXiduAbmL+GB21jrsuvbVl7R6In5n7w7iY7qz+I7S
         eObVxw4nLCd3UxEGDYOqvvCkQ5tdyfzVminsUCTMEsbnJgyWDoLA969OvjeDeI1793ZW
         7FbV/xKbWsg8FqxYd1Po3lsCzSooDvi+UBfXL1cvaAthBWZemVHraHKz+zR1y7LOimkp
         YPpagrhpfBcfSM8tQTukqJT7YgRJTWUHTI++N2TSkrCscfdS4cYIlkzPvjfZgiQT/bnI
         CifQ==
X-Gm-Message-State: APjAAAXAJMSjlQuUdHA21NPEyJ56Vv32OSmRa9DNma0pDOVVVfvTCied
	7ld5Xpyc8P1PCbMkClIoEPDcxg==
X-Google-Smtp-Source: APXvYqwsPae0vNSwigouHMUxOlp4cnOUahDfeE+W9gnOtVKDwdJdfx2UhKXwYdremGpJnC+o/jmyHQ==
X-Received: by 2002:a37:49d6:: with SMTP id w205mr35829035qka.191.1568215161746;
        Wed, 11 Sep 2019 08:19:21 -0700 (PDT)
Received: from qians-mbp.fios-router.home (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id g194sm11256279qke.46.2019.09.11.08.19.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Sep 2019 08:19:20 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH v3] mm/kasan: dump alloc and free stack for page allocator
From: Qian Cai <cai@lca.pw>
In-Reply-To: <20190911083921.4158-1-walter-zh.wu@mediatek.com>
Date: Wed, 11 Sep 2019 11:19:19 -0400
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>,
 Dmitry Vyukov <dvyukov@google.com>,
 Matthias Brugger <matthias.bgg@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Andrey Konovalov <andreyknvl@google.com>,
 Vlastimil Babka <vbabka@suse.cz>,
 Arnd Bergmann <arnd@arndb.de>,
 linux-kernel@vger.kernel.org,
 kasan-dev@googlegroups.com,
 linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org,
 linux-mediatek@lists.infradead.org,
 wsd_upstream@mediatek.com
Content-Transfer-Encoding: quoted-printable
Message-Id: <5E358F4B-552C-4542-9655-E01C7B754F14@lca.pw>
References: <20190911083921.4158-1-walter-zh.wu@mediatek.com>
To: Walter Wu <walter-zh.wu@mediatek.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Sep 11, 2019, at 4:39 AM, Walter Wu <walter-zh.wu@mediatek.com> =
wrote:
>=20
> This patch is KASAN's report adds the alloc/free stack for page =
allocator
> in order to help programmer to see memory corruption caused by the =
page.
>=20
> By default, KASAN doesn't record alloc or free stack for page =
allocator.
> It is difficult to fix up the page use-after-free or double-free =
issue.
>=20
> We add the following changing:
> 1) KASAN enable PAGE_OWNER by default to get the alloc stack of the =
page.
> 2) Add new feature option to get the free stack of the page.
>=20
> The new feature KASAN_DUMP_PAGE depends on DEBUG_PAGEALLOC, it will =
help
> to record free stack of the page, it is very helpful for solving the =
page
> use-after-free or double-free issue.
>=20
> When KASAN_DUMP_PAGE is enabled then KASAN's report will show the last
> alloc and free stack of the page, it should be:
>=20
> BUG: KASAN: use-after-free in kmalloc_pagealloc_uaf+0x70/0x80
> Write of size 1 at addr ffffffc0d60e4000 by task cat/115
> ...
> prep_new_page+0x1c8/0x218
> get_page_from_freelist+0x1ba0/0x28d0
> __alloc_pages_nodemask+0x1d4/0x1978
> kmalloc_order+0x28/0x58
> kmalloc_order_trace+0x28/0xe0
> kmalloc_pagealloc_uaf+0x2c/0x80
> page last free stack trace:
> __free_pages_ok+0x116c/0x1630
> __free_pages+0x50/0x78
> kfree+0x1c4/0x250
> kmalloc_pagealloc_uaf+0x38/0x80
>=20
> Changes since v1:
> - slim page_owner and move it into kasan
> - enable the feature by default
>=20
> Changes since v2:
> - enable PAGE_OWNER by default
> - use DEBUG_PAGEALLOC to get page information
>=20
> cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> cc: Vlastimil Babka <vbabka@suse.cz>
> cc: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Walter Wu <walter-zh.wu@mediatek.com>
> ---
> lib/Kconfig.kasan | 15 +++++++++++++++
> 1 file changed, 15 insertions(+)
>=20
> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> index 4fafba1a923b..4d59458c0c5a 100644
> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
> @@ -41,6 +41,7 @@ config KASAN_GENERIC
> 	select SLUB_DEBUG if SLUB
> 	select CONSTRUCTORS
> 	select STACKDEPOT
> +	select PAGER_OWNER
> 	help
> 	  Enables generic KASAN mode.
> 	  Supported in both GCC and Clang. With GCC it requires version =
4.9.2
> @@ -63,6 +64,7 @@ config KASAN_SW_TAGS
> 	select SLUB_DEBUG if SLUB
> 	select CONSTRUCTORS
> 	select STACKDEPOT
> +	select PAGER_OWNER
> 	help
> 	  Enables software tag-based KASAN mode.
> 	  This mode requires Top Byte Ignore support by the CPU and =
therefore
> @@ -135,6 +137,19 @@ config KASAN_S390_4_LEVEL_PAGING
> 	  to 3TB of RAM with KASan enabled). This options allows to =
force
> 	  4-level paging instead.
>=20
> +config KASAN_DUMP_PAGE
> +	bool "Dump the last allocation and freeing stack of the page"
> +	depends on KASAN
> +	select DEBUG_PAGEALLOC
> +	help
> +	  By default, KASAN enable PAGE_OWNER only to record alloc stack
> +	  for page allocator. It is difficult to fix up page =
use-after-free
> +	  or double-free issue.
> +	  This feature depends on DEBUG_PAGEALLOC, it will extra record
> +	  free stack of page. It is very helpful for solving the page
> +	  use-after-free or double-free issue.
> +	  This option will have a small memory overhead.
> +
> config TEST_KASAN
> 	tristate "Module for testing KASAN for bug detection"
> 	depends on m && KASAN
> =E2=80=94=20

The new config looks redundant and confusing. It looks to me more of a =
document update
in Documentation/dev-tools/kasan.txt to educate developers to select =
PAGE_OWNER and
DEBUG_PAGEALLOC if needed.


