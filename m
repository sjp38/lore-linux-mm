Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C67496B02FD
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 12:05:32 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id g21so47578005ioe.12
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 09:05:32 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id o74si1534514ito.48.2017.08.11.09.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 09:05:31 -0700 (PDT)
Subject: Re: [v6 09/15] sparc64: optimized struct page zeroing
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-10-git-send-email-pasha.tatashin@oracle.com>
 <20170811125326.GK30811@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <3830e513-cb35-e52e-341c-25eaecc51d43@oracle.com>
Date: Fri, 11 Aug 2017 12:04:51 -0400
MIME-Version: 1.0
In-Reply-To: <20170811125326.GK30811@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

>> Add an optimized mm_zero_struct_page(), so struct page's are zeroed without
>> calling memset(). We do eight to tent regular stores based on the size of
>> struct page. Compiler optimizes out the conditions of switch() statement.
> 
> Again, this doesn't explain why we need this. You have mentioned those
> reasons in some previous emails but be explicit here please.
> 

I will add performance data to this patch as well.

Thank you,
Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
