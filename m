Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C56556B025F
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 13:17:21 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id o2so1383265lfe.10
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 10:17:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t19sor1776700ljd.35.2017.10.18.10.17.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Oct 2017 10:17:20 -0700 (PDT)
Subject: Re: [PATCH v12 07/11] x86/kasan: add and use kasan_map_populate()
References: <20171013173214.27300-1-pasha.tatashin@oracle.com>
 <20171013173214.27300-8-pasha.tatashin@oracle.com>
 <f4540f92-2229-53f5-ee74-fe160bedc873@virtuozzo.com>
 <6fd8291b-b3f5-46c1-2650-98a775e37fa0@oracle.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <56120ddc-e03e-dbac-50c4-adb2287ec407@gmail.com>
Date: Wed, 18 Oct 2017 20:20:27 +0300
MIME-Version: 1.0
In-Reply-To: <6fd8291b-b3f5-46c1-2650-98a775e37fa0@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, akpm@linux-foundation.org, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On 10/18/2017 08:14 PM, Pavel Tatashin wrote:
> Thank you Andrey, I will test this patch. Should it go on top or replace the existing patch in mm-tree? ARM and x86 should be done the same either both as follow-ups or both replace.
> 

 It's a replacement of your patch.


> Pavel
> 
> -- 
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.A  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
