Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C22E96B025F
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 09:20:54 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id y68so18368197qka.2
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 06:20:54 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d6si5225807qta.281.2017.08.30.06.20.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 06:20:53 -0700 (PDT)
Subject: Re: [PATCH v7 07/11] sparc64: optimized struct page zeroing
References: <1503972142-289376-1-git-send-email-pasha.tatashin@oracle.com>
 <1503972142-289376-8-git-send-email-pasha.tatashin@oracle.com>
 <20170829.181208.171985548699678313.davem@davemloft.net>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <e07c05b1-c0be-bf7f-9a29-11dc41b79d10@oracle.com>
Date: Wed, 30 Aug 2017 09:19:58 -0400
MIME-Version: 1.0
In-Reply-To: <20170829.181208.171985548699678313.davem@davemloft.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steven.Sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Dave,

Thank you for acking.

The reason I am not doing initializing stores is because they require a 
membar, even if only regular stores are following (I hoped to do a 
membar before first load). This is something I was thinking was not 
true, but after consulting with colleagues and checking processor 
manual, I verified that it is the case.

Pasha

> 
> You should probably use initializing stores when you are doing 8
> stores and we thus know the page struct is cache line aligned.
> 
> But other than that:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
