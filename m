Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 213A86B0008
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 07:11:25 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id t12-v6so5081806plo.9
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 04:11:25 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50093.outbound.protection.outlook.com. [40.107.5.93])
        by mx.google.com with ESMTPS id i12si3952017pgp.7.2018.03.02.04.11.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 02 Mar 2018 04:11:24 -0800 (PST)
Subject: Re: [PATCH 2/2] kasan: disallow compiler to optimize away memset in
 tests
References: <cover.1519924383.git.andreyknvl@google.com>
 <105ec9a308b2abedb1a0d1fdced0c22d765e4732.1519924383.git.andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <41d0e9bd-9102-6a50-e0d6-c193696381c9@virtuozzo.com>
Date: Fri, 2 Mar 2018 15:11:56 +0300
MIME-Version: 1.0
In-Reply-To: <105ec9a308b2abedb1a0d1fdced0c22d765e4732.1519924383.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Nick Terrell <terrelln@fb.com>, Chris Mason <clm@fb.com>, Yury Norov <ynorov@caviumnetworks.com>, Al Viro <viro@zeniv.linux.org.uk>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Palmer Dabbelt <palmer@dabbelt.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Jeff Layton <jlayton@redhat.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Cc: Kostya Serebryany <kcc@google.com>



On 03/01/2018 08:15 PM, Andrey Konovalov wrote:
> A compiler can optimize away memset calls by replacing them with mov
> instructions. There are KASAN tests, that specifically test that KASAN
> correctly handles memset calls, we don't want this optimization to
> happen.
> 
> The solution is to add -fno-builtin flag to test_kasan.ko
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
