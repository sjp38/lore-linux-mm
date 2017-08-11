Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 27AE16B02F4
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 12:25:07 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id v17so64281104ywh.15
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 09:25:07 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k10si337754ybg.277.2017.08.11.09.25.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 09:25:06 -0700 (PDT)
Subject: Re: [v6 07/15] mm: defining memblock_virt_alloc_try_nid_raw
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-8-git-send-email-pasha.tatashin@oracle.com>
 <20170811123953.GI30811@dhcp22.suse.cz>
 <545b7230-2c09-d2f9-f26a-05ef395c36d4@oracle.com>
 <20170811160646.GT30811@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <1d93e0eb-080a-ed2b-de2d-092f397a981c@oracle.com>
Date: Fri, 11 Aug 2017 12:24:27 -0400
MIME-Version: 1.0
In-Reply-To: <20170811160646.GT30811@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

>> Sure, I could do this, but as I understood from earlier Dave Miller's
>> comments, we should do one logical change at a time. Hence, introduce API in
>> one patch use it in another. So, this is how I tried to organize this patch
>> set. Is this assumption incorrect?
> 
> Well, it really depends. If the patch is really small then adding a new
> API along with users is easier to review and backport because you have a
> clear view of the usage. I believe this is the case here. But if others
> feel otherwise I will not object.

I will merge them.

Thank you,
Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
