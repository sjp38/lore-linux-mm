Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 306B66B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 11:23:05 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id 62so295456290oif.2
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 08:23:05 -0800 (PST)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40116.outbound.protection.outlook.com. [40.107.4.116])
        by mx.google.com with ESMTPS id f133si187883oia.164.2016.11.09.08.23.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 08:23:04 -0800 (PST)
Subject: Re: [PATCH 2/2] kasan: improve error reports
References: <cover.1478632698.git.andreyknvl@google.com>
 <12f35b740fd59901898c72c837600f5f4e1c2d56.1478632698.git.andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <f1f4d819-68e4-ff3d-d549-a53bcb60bec9@virtuozzo.com>
Date: Wed, 9 Nov 2016 19:23:18 +0300
MIME-Version: 1.0
In-Reply-To: <12f35b740fd59901898c72c837600f5f4e1c2d56.1478632698.git.andreyknvl@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@redhat.com
Cc: kcc@google.com

On 11/08/2016 10:37 PM, Andrey Konovalov wrote:
> 1. Change header format.
> 2. Unify header format between different kinds of bad accesses.
> 3. Add empty lines between parts of the report to improve readability.
> 4. Improve slab object description.
> 5. Improve mm/kasan/report.c readability.
> 

Can you please do not dump everything in one patch? It only makes review process much more complicated.
Please break it up into 'one patch per logical change'.

> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
