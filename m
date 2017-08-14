Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id C22F56B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:39:55 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id a123so42716937vkc.11
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 06:39:55 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p44si3486322uae.339.2017.08.14.06.39.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 06:39:55 -0700 (PDT)
Subject: Re: [v6 04/15] mm: discard memblock data later
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-5-git-send-email-pasha.tatashin@oracle.com>
 <20170811093249.GE30811@dhcp22.suse.cz>
 <42a04441-47ad-2fa0-ca3c-784c717213f7@oracle.com>
 <20170814113445.GE19063@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <aac7b5f1-5c5e-e716-af49-bc150449ddbc@oracle.com>
Date: Mon, 14 Aug 2017 09:39:17 -0400
MIME-Version: 1.0
In-Reply-To: <20170814113445.GE19063@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, Mel Gorman <mgorman@suse.de>

>> #ifdef CONFIG_MEMBLOCK in page_alloc, or define memblock_discard() stubs in
>> nobootmem headfile.
> 
> This is the standard way to do this. And it is usually preferred to
> proliferate ifdefs in the code.

Hi Michal,

As you suggested, I sent-out this patch separately. If you feel 
strongly, that this should be updated to have stubs for platforms that 
do not implement memblock, please send a reply to that e-mail, so those 
who do not follow this tread will see it. Otherwise, I can leave it as 
is, page_alloc file already has a number memblock related ifdefs all of 
which can be cleaned out once every platform implements it (is it even 
achievable?)

Thank you,
Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
