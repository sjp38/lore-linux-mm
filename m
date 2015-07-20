Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 630949003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 16:40:51 -0400 (EDT)
Received: by padck2 with SMTP id ck2so106128968pad.0
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 13:40:51 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0063.outbound.protection.outlook.com. [157.56.112.63])
        by mx.google.com with ESMTPS id df1si38249663pad.84.2015.07.20.13.40.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 20 Jul 2015 13:40:50 -0700 (PDT)
Subject: Re: [PATCH V3 4/5] mm: mmap: Add mmap flag to request VM_LOCKONFAULT
References: <1436288623-13007-1-git-send-email-emunson@akamai.com>
 <1436288623-13007-5-git-send-email-emunson@akamai.com>
 <CAP=VYLq5=9DCfncJpQizcSbQt1O7VL2yEdzZNOFK+M3pqLpb3Q@mail.gmail.com>
From: Chris Metcalf <cmetcalf@ezchip.com>
Message-ID: <55AD5CB9.4090400@ezchip.com>
Date: Mon, 20 Jul 2015 16:40:25 -0400
MIME-Version: 1.0
In-Reply-To: <CAP=VYLq5=9DCfncJpQizcSbQt1O7VL2yEdzZNOFK+M3pqLpb3Q@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>, Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-arch <linux-arch@vger.kernel.org>, linux-api@vger.kernel.org, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>

On 07/18/2015 03:11 PM, Paul Gortmaker wrote:
> On Tue, Jul 7, 2015 at 1:03 PM, Eric B Munson<emunson@akamai.com>  wrote:
>> >The cost of faulting in all memory to be locked can be very high when
>> >working with large mappings.  If only portions of the mapping will be
>> >used this can incur a high penalty for locking.
>> >
>> >Now that we have the new VMA flag for the locked but not present state,
>> >expose it  as an mmap option like MAP_LOCKED -> VM_LOCKED.
> An automatic bisection on arch/tile leads to this commit:
>
> 5a5656f2c9b61c74c15f9ef3fa2e6513b6c237bb is the first bad commit
> commit 5a5656f2c9b61c74c15f9ef3fa2e6513b6c237bb
> Author: Eric B Munson<emunson@akamai.com>
> Date:   Thu Jul 16 10:09:22 2015 +1000
>
>      mm: mmap: add mmap flag to request VM_LOCKONFAULT

Eric, I'm happy to help with figuring out the tile issues.

-- 
Chris Metcalf, EZChip Semiconductor
http://www.ezchip.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
