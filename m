Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5150C6B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 21:18:17 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id f128so62182836qkb.1
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 18:18:17 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id i3si8254109qti.50.2016.10.13.18.18.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 18:18:16 -0700 (PDT)
Subject: Re: [RFC v2 PATCH] mm/percpu.c: simplify grouping CPU algorithm
References: <701fa92a-026b-f30b-833c-a5e61eab6549@zoho.com>
 <20161013233722.GF32534@mtj.duckdns.org>
 <b1e98606-be69-0dd6-0a50-1b19e6237dc5@zoho.com>
 <20161014003313.GI32534@mtj.duckdns.org>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <62b744a3-4206-a25e-b8eb-1fd18953b4f3@zoho.com>
Date: Fri, 14 Oct 2016 09:17:48 +0800
MIME-Version: 1.0
In-Reply-To: <20161014003313.GI32534@mtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, cl@linux.com

On 2016/10/14 8:33, Tejun Heo wrote:
> Hello,
> 
> On Fri, Oct 14, 2016 at 07:49:44AM +0800, zijun_hu wrote:
>> the main intent of this change is making the CPU grouping algorithm more
>> easily to understand, especially, for newcomer for memory managements
>> take me as a example, i really take me a longer timer to understand it
> 
> If the new code is easier to understand, it's only so marginally.  It
> just isn't worth the effort or risk.
> 
> Thanks.
> 
okay i agree with your opinion.
but i am sure this changes don't have any risk after tests and theoretic analyse


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
