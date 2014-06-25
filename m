Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3A46B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 21:08:31 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id ma3so966959pbc.0
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 18:08:31 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id kc4si2703253pad.223.2014.06.24.18.08.29
        for <linux-mm@kvack.org>;
        Tue, 24 Jun 2014 18:08:30 -0700 (PDT)
Message-ID: <53AA1E5F.10800@cn.fujitsu.com>
Date: Wed, 25 Jun 2014 08:57:03 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mempolicy: fix sleeping function called from invalid
 context
References: <53902A44.50005@cn.fujitsu.com> <20140605132339.ddf6df4a0cf5c14d17eb8691@linux-foundation.org> <539192F1.7050308@cn.fujitsu.com> <alpine.DEB.2.02.1406081539140.21744@chino.kir.corp.google.com> <539574F1.2060701@cn.fujitsu.com> <alpine.DEB.2.02.1406090209460.24247@chino.kir.corp.google.com> <53967465.7070908@huawei.com> <20140620210137.GA2059@mtj.dyndns.org> <53A8E23C.4050103@huawei.com> <20140624205832.GB14909@htj.dyndns.org>
In-Reply-To: <20140624205832.GB14909@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>, stable@vger.kernel.org

Hi Tejun,
On 06/25/2014 04:58 AM, Tejun Heo wrote:

> Hello,
> 
> On Tue, Jun 24, 2014 at 10:28:12AM +0800, Li Zefan wrote:
>>> I don't think the suggested patch breaks anything more than it was
>>> broken before and we should probably apply it for the time being.  Li?
>>
>> Yeah, we should apply Gu Zheng's patch any way.
> 
> Gu Zheng, can you please respin the patch with updated explanation on
> the temporary nature of the change.  I'll apply it once Li acks it.

OK, I'll resend it soon.

Regards,
Gu

> 
> Thanks.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
