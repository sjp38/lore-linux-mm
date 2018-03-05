Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id DED316B0005
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:45:09 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id p203so9974414itc.1
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:45:09 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id f185si6653429ith.19.2018.03.05.12.45.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 12:45:08 -0800 (PST)
Subject: Re: [PATCH v12 09/11] mm: Allow arch code to override copy_highpage()
References: <cover.1519227112.git.khalid.aziz@oracle.com>
 <ecbafa2bfcc05f22183be2e7784ed11943b1d5b2.1519227112.git.khalid.aziz@oracle.com>
 <68ee1cbc-8e21-e693-7878-777e0d5b0f0c@linux.intel.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <8b441f99-ee41-e113-f52d-dbe0573bf267@oracle.com>
Date: Mon, 5 Mar 2018 13:42:25 -0700
MIME-Version: 1.0
In-Reply-To: <68ee1cbc-8e21-e693-7878-777e0d5b0f0c@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, akpm@linux-foundation.org, davem@davemloft.net
Cc: kstewart@linuxfoundation.org, pombredanne@nexb.com, tglx@linutronix.de, anthony.yznaga@oracle.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

On 03/05/2018 12:24 PM, Dave Hansen wrote:
> On 02/21/2018 09:15 AM, Khalid Aziz wrote:
>> +#ifndef __HAVE_ARCH_COPY_HIGHPAGE
>> +
>>   static inline void copy_highpage(struct page *to, struct page *from)
>>   {
>>   	char *vfrom, *vto;
>> @@ -248,4 +250,6 @@ static inline void copy_highpage(struct page *to, struct page *from)
>>   	kunmap_atomic(vfrom);
>>   }
>>   
>> +#endif
> 
> I think we prefer that these are CONFIG_* options.

I added this mechanism to be same as what we have for copy_user_highpage():

---------------
#ifndef __HAVE_ARCH_COPY_USER_HIGHPAGE

static inline void copy_user_highpage(struct page *to, struct page *from,
         unsigned long vaddr, struct vm_area_struct *vma)
{
----------------

There isn't a CONFIG_* option for copy_user_highpage() so I don't see a 
reason to add one for copy_highpage().

Do you see it differently? In that case, should there be a CONFIG_* 
option for copy_user_highpage() as well?

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
