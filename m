Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id F34D1280850
	for <linux-mm@kvack.org>; Sun, 21 May 2017 08:58:48 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id l145so62539168ita.14
        for <linux-mm@kvack.org>; Sun, 21 May 2017 05:58:48 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id x127si29862850itb.55.2017.05.21.05.58.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 May 2017 05:58:48 -0700 (PDT)
Subject: Re: [v4 1/1] mm: Adaptive hash table scaling
References: <1495300013-653283-1-git-send-email-pasha.tatashin@oracle.com>
 <1495300013-653283-2-git-send-email-pasha.tatashin@oracle.com>
 <87h90faroe.fsf@firstfloor.org>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <a09bba26-8461-653d-6b43-2df897a238f0@oracle.com>
Date: Sun, 21 May 2017 08:58:25 -0400
MIME-Version: 1.0
In-Reply-To: <87h90faroe.fsf@firstfloor.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org

Hi Andi,

Thank you for looking at this. I mentioned earlier, I would not want to 
impose a cap. However, if you think that for example dcache needs a cap, 
there is already a mechanism for that via high_limit argument, so the 
client can be changed to provide that cap. However, this particular 
patch addresses scaling problem for everyone by making it scale with 
memory at a slower pace.

Thank you,
Pasha

On 05/20/2017 10:07 PM, Andi Kleen wrote:
> Pavel Tatashin <pasha.tatashin@oracle.com> writes:
> 
>> Allow hash tables to scale with memory but at slower pace, when HASH_ADAPT
>> is provided every time memory quadruples the sizes of hash tables will only
>> double instead of quadrupling as well. This algorithm starts working only
>> when memory size reaches a certain point, currently set to 64G.
>>
>> This is example of dentry hash table size, before and after four various
>> memory configurations:
> 
> IMHO the scale is still too aggressive. I find it very unlikely
> that a 1TB machine really needs 256MB of hash table because
> number of used files are unlikely to directly scale with memory.
> 
> Perhaps should just cap it at some large size, e.g. 32M
> 
> -Andi
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
