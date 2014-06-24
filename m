Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3EC6B0031
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 20:34:34 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y13so6311408pdi.27
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 17:34:34 -0700 (PDT)
Received: from fgwmail.fujitsu.co.jp (fgwmail.fujitsu.co.jp. [164.71.1.133])
        by mx.google.com with ESMTPS id sk2si1361518pbc.169.2014.06.23.17.34.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 17:34:33 -0700 (PDT)
Received: from kw-mxoi1.gw.nic.fujitsu.com (unknown [10.0.237.133])
	by fgwmail.fujitsu.co.jp (Postfix) with ESMTP id BE2D53EE0B6
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 09:34:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.nic.fujitsu.com [10.0.50.92])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 4ED93AC0667
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 09:34:31 +0900 (JST)
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D1E6A1DB8046
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 09:34:30 +0900 (JST)
Message-ID: <53A8C76A.4060207@jp.fujitsu.com>
Date: Tue, 24 Jun 2014 09:33:46 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] x86,mem-hotplug: pass sync_global_pgds() a correct
 argument in remove_pagetable()
References: <53A132E2.9000605@jp.fujitsu.com>	 <53A1339E.2000000@jp.fujitsu.com> <1403288831.25108.0.camel@misato.fc.hp.com>
In-Reply-To: <1403288831.25108.0.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, tangchen@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, guz.fnst@cn.fujitsu.com, zhangyanfei@cn.fujitsu.com

(2014/06/21 3:27), Toshi Kani wrote:
> On Wed, 2014-06-18 at 15:37 +0900, Yasuaki Ishimatsu wrote:
>> remove_pagetable() gets start argument and passes the argument to
>> sync_global_pgds(). In this case, the argument must not be modified.
>> If the argument is modified and passed to sync_global_pgds(),
>> sync_global_pgds() does not correctly synchronize PGD to PGD entries
>> of all processes MM since synchronized range of memory [start, end]
>> is wrong.
>>
>> Unfortunately the start argument is modified in remove_pagetable().
>> So this patch fixes the issue.
>>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>

> Acked-by: Toshi Kani <toshi.kani@hp.com>

Thank you for your review.

Thanks,
Yasuak Ishimatsu

>
> Thanks,
> -Toshi
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
