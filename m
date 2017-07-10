Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED8B44084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:31:38 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id h47so54343235qta.12
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 10:31:38 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p22si11086924qtg.225.2017.07.10.10.31.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 10:31:37 -0700 (PDT)
Subject: Re: [PATCH] mm/mremap: Document MREMAP_FIXED dependency on
 MREMAP_MAYMOVE
References: <20170710113211.31394-1-khandual@linux.vnet.ibm.com>
 <20170710134130.GA19645@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <40c61daf-da2c-bab9-99d0-a7d7147f4514@oracle.com>
Date: Mon, 10 Jul 2017 10:31:29 -0700
MIME-Version: 1.0
In-Reply-To: <20170710134130.GA19645@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On 07/10/2017 06:41 AM, Michal Hocko wrote:
> On Mon 10-07-17 17:02:11, Anshuman Khandual wrote:
>> In the header file, just specify the dependency of MREMAP_FIXED
>> on MREMAP_MAYMOVE and make it explicit for the user space.
> 
> I really fail to see a point of this patch. The depency belongs to the
> code and it seems that we already enforce it
> 	if (flags & MREMAP_FIXED && !(flags & MREMAP_MAYMOVE))
> 		return ret;
> 
> So what is the point here?

Agree, I am not sure of your reasoning.

If to assist the programmer, there is no need as this is clearly specified
in the man page:

"If  MREMAP_FIXED  is  specified,  then MREMAP_MAYMOVE must also be
 specified."

-- 
Mike Kravetz

> 
>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>> ---
>>  include/uapi/linux/mman.h | 6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/uapi/linux/mman.h b/include/uapi/linux/mman.h
>> index ade4acd..8cae3f6 100644
>> --- a/include/uapi/linux/mman.h
>> +++ b/include/uapi/linux/mman.h
>> @@ -3,8 +3,10 @@
>>  
>>  #include <asm/mman.h>
>>  
>> -#define MREMAP_MAYMOVE	1
>> -#define MREMAP_FIXED	2
>> +#define MREMAP_MAYMOVE	1 /* VMA can move after remap and resize */
>> +#define MREMAP_FIXED	2 /* VMA can remap at particular address */
>> +
>> +/* NOTE: MREMAP_FIXED must be set with MREMAP_MAYMOVE, not alone */
>>  
>>  #define OVERCOMMIT_GUESS		0
>>  #define OVERCOMMIT_ALWAYS		1
>> -- 
>> 1.8.5.2
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
