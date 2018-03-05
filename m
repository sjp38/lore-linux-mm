Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 547B76B0003
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:56:55 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id o61-v6so8626395pld.5
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:56:55 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id w25si10808041pfk.99.2018.03.05.12.56.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 12:56:54 -0800 (PST)
Subject: Re: [PATCH v12 09/11] mm: Allow arch code to override copy_highpage()
References: <cover.1519227112.git.khalid.aziz@oracle.com>
 <ecbafa2bfcc05f22183be2e7784ed11943b1d5b2.1519227112.git.khalid.aziz@oracle.com>
 <68ee1cbc-8e21-e693-7878-777e0d5b0f0c@linux.intel.com>
 <8b441f99-ee41-e113-f52d-dbe0573bf267@oracle.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <2a558ec8-c46c-299e-2f14-bb33058cbd90@linux.intel.com>
Date: Mon, 5 Mar 2018 12:56:52 -0800
MIME-Version: 1.0
In-Reply-To: <8b441f99-ee41-e113-f52d-dbe0573bf267@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, akpm@linux-foundation.org, davem@davemloft.net
Cc: kstewart@linuxfoundation.org, pombredanne@nexb.com, tglx@linutronix.de, anthony.yznaga@oracle.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

On 03/05/2018 12:42 PM, Khalid Aziz wrote:
> On 03/05/2018 12:24 PM, Dave Hansen wrote:
>> On 02/21/2018 09:15 AM, Khalid Aziz wrote:
>>> +#ifndef __HAVE_ARCH_COPY_HIGHPAGE
>>> +
>>> A  static inline void copy_highpage(struct page *to, struct page *from)
>>> A  {
>>> A A A A A  char *vfrom, *vto;
>>> @@ -248,4 +250,6 @@ static inline void copy_highpage(struct page *to,
>>> struct page *from)
>>> A A A A A  kunmap_atomic(vfrom);
>>> A  }
>>> A  +#endif
>>
>> I think we prefer that these are CONFIG_* options.
> 
> I added this mechanism to be same as what we have for copy_user_highpage():
> 
> ---------------
> #ifndef __HAVE_ARCH_COPY_USER_HIGHPAGE

I think that's the old way that we generally don't want to add new
instances of.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
