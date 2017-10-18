Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 764806B025F
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 13:14:54 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 10so6481342qty.10
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 10:14:54 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id q196si299698qke.194.2017.10.18.10.14.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 10:14:53 -0700 (PDT)
Subject: Re: [PATCH v12 07/11] x86/kasan: add and use kasan_map_populate()
References: <20171013173214.27300-1-pasha.tatashin@oracle.com>
 <20171013173214.27300-8-pasha.tatashin@oracle.com>
 <f4540f92-2229-53f5-ee74-fe160bedc873@virtuozzo.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <6fd8291b-b3f5-46c1-2650-98a775e37fa0@oracle.com>
Date: Wed, 18 Oct 2017 13:14:11 -0400
MIME-Version: 1.0
In-Reply-To: <f4540f92-2229-53f5-ee74-fe160bedc873@virtuozzo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, akpm@linux-foundation.org, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Thank you Andrey, I will test this patch. Should it go on top or replace 
the existing patch in mm-tree? ARM and x86 should be done the same 
either both as follow-ups or both replace.

Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
