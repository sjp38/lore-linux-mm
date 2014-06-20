Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 410AC6B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 14:36:31 -0400 (EDT)
Received: by mail-yk0-f179.google.com with SMTP id 20so2935331yks.24
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 11:36:31 -0700 (PDT)
Received: from g5t1627.atlanta.hp.com (g5t1627.atlanta.hp.com. [15.192.137.10])
        by mx.google.com with ESMTPS id 61si9936121yho.139.2014.06.20.11.36.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 11:36:30 -0700 (PDT)
Message-ID: <1403288831.25108.0.camel@misato.fc.hp.com>
Subject: Re: [PATCH 1/2] x86,mem-hotplug: pass sync_global_pgds() a correct
 argument in remove_pagetable()
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 20 Jun 2014 12:27:11 -0600
In-Reply-To: <53A1339E.2000000@jp.fujitsu.com>
References: <53A132E2.9000605@jp.fujitsu.com>
	 <53A1339E.2000000@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, tangchen@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, guz.fnst@cn.fujitsu.com, zhangyanfei@cn.fujitsu.com

On Wed, 2014-06-18 at 15:37 +0900, Yasuaki Ishimatsu wrote:
> remove_pagetable() gets start argument and passes the argument to
> sync_global_pgds(). In this case, the argument must not be modified.
> If the argument is modified and passed to sync_global_pgds(),
> sync_global_pgds() does not correctly synchronize PGD to PGD entries
> of all processes MM since synchronized range of memory [start, end]
> is wrong.
> 
> Unfortunately the start argument is modified in remove_pagetable().
> So this patch fixes the issue.
> 
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Acked-by: Toshi Kani <toshi.kani@hp.com>

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
