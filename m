Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id F14B96B0261
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 13:08:57 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id a32so2680519wrc.12
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 10:08:57 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id h63si508053edc.177.2017.10.18.10.08.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 10:08:57 -0700 (PDT)
Subject: Re: [PATCH v12 08/11] arm64/kasan: add and use kasan_map_populate()
References: <20171013173214.27300-1-pasha.tatashin@oracle.com>
 <20171013173214.27300-9-pasha.tatashin@oracle.com>
 <0ae84532-8dcb-10aa-9d69-79d7025b089e@virtuozzo.com>
 <ad8c5715-dc4f-1fa7-c25b-e08df68643d0@oracle.com>
 <20171018170651.GG21820@arm.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <e32c677e-62ac-8977-2f9d-7fe7bda4b547@oracle.com>
Date: Wed, 18 Oct 2017 13:08:17 -0400
MIME-Version: 1.0
In-Reply-To: <20171018170651.GG21820@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, akpm@linux-foundation.org, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

> 
> As I said, I'm fine either way, I just didn't want to cause extra work
> or rebasing:
> 
> http://lists.infradead.org/pipermail/linux-arm-kernel/2017-October/535703.html

Makes sense. I am also fine either way, I can submit a new patch merging 
together the two if needed.

Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
