Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 20D776B0035
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 21:10:46 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id f11so1054730qae.12
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 18:10:45 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id y5si967549qar.62.2013.11.22.18.10.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Nov 2013 18:10:42 -0800 (PST)
Message-ID: <52900E95.3050106@infradead.org>
Date: Fri, 22 Nov 2013 18:10:29 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: remove the redundant declaration of kmalloc
References: <528DA0C0.8010505@huawei.com> <528E5AEF.6020007@infradead.org> <528EAE3E.5080604@huawei.com>
In-Reply-To: <528EAE3E.5080604@huawei.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Huang <h.huangqiang@huawei.com>, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 11/21/13 17:07, Qiang Huang wrote:
> On 2013/11/22 3:11, Randy Dunlap wrote:
>> On 11/20/13 21:57, Qiang Huang wrote:
>>>
>>> Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>
>>
>> or use my patch from 2013-09-17:
>> http://marc.info/?l=linux-mm&m=137944291611467&w=2
>>
>> Would be nice to one of these merged...
> 
> Yes, sorry for not notice this, merge your patch should be property :)
> But why it's still not be merged?
> 
> Ping...

I don't know.  I'll resend it now.


Thanks.


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
