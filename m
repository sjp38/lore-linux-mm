Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4B14A6B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 20:54:04 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id y38so67977238qta.6
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 17:54:04 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id w21si8211859qtw.46.2016.10.13.17.54.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 17:54:03 -0700 (PDT)
Subject: Re: [RFC v2 PATCH] mm/percpu.c: fix panic triggered by BUG_ON()
 falsely
References: <57FCF07C.2020103@zoho.com>
 <20161013232902.GD32534@mtj.duckdns.org>
 <92d3e474-856a-7f78-a9c3-b83e5913cd13@zoho.com>
 <20161014002441.GG32534@mtj.duckdns.org>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <2483aa44-ec1e-e523-ebfc-341f71319608@zoho.com>
Date: Fri, 14 Oct 2016 08:52:31 +0800
MIME-Version: 1.0
In-Reply-To: <20161014002441.GG32534@mtj.duckdns.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, cl@linux.com

On 2016/10/14 8:24, Tejun Heo wrote:
> Hello,
> 
> On Fri, Oct 14, 2016 at 08:06:10AM +0800, zijun_hu wrote:
>>> I really can't decode what the actual issue is here.  Can you please
>>> give an example of a concrete case?
>>>
>> the right relationship between the number of CPUs @nr_cpus within a percpu group
>> and the number of unites @nr_units within the same group is that
>> @nr_units == roundup(@nr_cpus, @upa);
> 
> My question was whether there can be actual hardware configurations
> where this code can fail and if so what they look like and how they
> would fail.
> 
> Thanks.
> 
this answer is difficult to answer since there are so many hardware configurations
moreover, besides hardware configuration, reserved size can contribute to this issue
as we known, this interface is developed for various ARCHs to setups percpu areas, 
so we should not assume more detailed aspects about ARCH. neither hardware config
nor reserved size.

i am learning memory management code and find the inconsistency between here and
there. the log is similar with a panic triggered by BUG_ON() if the numbers of
CPUs isn't aligned to @upa

are you agree the relationship of between CPU and units? 
what bad effects do this changes results in?

are you sure all hardware configurations and reserved size always make number of CPUs
are equal to units? if turei 1/4 ? is it redundant for the consideration in there place.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
