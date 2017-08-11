Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8AD9C6B02B4
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 12:04:20 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id t37so19481955qtg.6
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 09:04:20 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id o39si1077741qtk.292.2017.08.11.09.04.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 09:04:19 -0700 (PDT)
Subject: Re: [v6 08/15] mm: zero struct pages during initialization
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-9-git-send-email-pasha.tatashin@oracle.com>
 <20170811125047.GJ30811@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <f81f5eaa-109e-666e-7020-84c090721a56@oracle.com>
Date: Fri, 11 Aug 2017 12:03:38 -0400
MIME-Version: 1.0
In-Reply-To: <20170811125047.GJ30811@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

> I believe this deserves much more detailed explanation why this is safe.
> What actually prevents any pfn walker from seeing an uninitialized
> struct page? Please make your assumptions explicit in the commit log so
> that we can check them independently.

There is nothing prevents pfn walkers from walk over any struct pages 
deferred and non-deferred. However, during boot before deferred pages 
are initialized we have just a few places that do that, and all of those 
cases are fixed in this patchset.

> Also this is done with some purpose which is the perfmance, right? You
> have mentioned that in the cover letter but if somebody is going to read
> through git logs this wouldn't be obvious from the specific commit.
> So add that information here as well. Especially numbers will be
> interesting.

I will add more performance data to this patch comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
