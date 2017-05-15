Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id AAFB66B02EE
	for <linux-mm@kvack.org>; Mon, 15 May 2017 14:12:26 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id q81so92673645itc.9
        for <linux-mm@kvack.org>; Mon, 15 May 2017 11:12:26 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b135si11354372iob.220.2017.05.15.11.12.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 11:12:25 -0700 (PDT)
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
References: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
 <20170509181234.GA4397@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <e19b241d-be27-3c9a-8984-2fb20211e2e1@oracle.com>
Date: Mon, 15 May 2017 14:12:10 -0400
MIME-Version: 1.0
In-Reply-To: <20170509181234.GA4397@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net

Hi Michal,

After looking at your suggested memblock_virt_alloc_core() change again, 
I decided to keep what I have. I do not want to inline 
memblock_virt_alloc_internal(), because it is not a performance critical 
path, and by inlining it we will unnecessarily increase the text size on 
all platforms.

Also, because it will be very hard to make sure that no platform 
regresses by making memset() default in _memblock_virt_alloc_core() (as 
I already showed last week at least sun4v SPARC64 will require special 
changes in order for this to work), I decided to make it available only 
for "deferred struct page init" case. As, what is already in the patch.

I am working on testing to make sure we do not need to double zero in 
the two cases that you found: sparsemem, and mem hotplug. Please let me 
know if you have any more comments, or if I can send new patches out 
when they are ready.

Thank you,
Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
