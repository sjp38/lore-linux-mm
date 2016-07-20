Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7EBBC6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 22:30:09 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so72795772pfa.2
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 19:30:09 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id i3si563089pfg.113.2016.07.19.19.30.07
        for <linux-mm@kvack.org>;
        Tue, 19 Jul 2016 19:30:08 -0700 (PDT)
Subject: Re: [PATCH v8 1/7] x86, memhp, numa: Online memory-less nodes at boot
 time.
References: <1468913288-16605-1-git-send-email-douly.fnst@cn.fujitsu.com>
 <1468913288-16605-2-git-send-email-douly.fnst@cn.fujitsu.com>
 <20160719185017.GM3078@mtj.duckdns.org>
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Message-ID: <bd359a28-7187-cec7-e83b-f7444f1b09a6@cn.fujitsu.com>
Date: Wed, 20 Jul 2016 10:28:29 +0800
MIME-Version: 1.0
In-Reply-To: <20160719185017.GM3078@mtj.duckdns.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, rafael@kernel.org, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

a?? 2016a1'07ae??20ae?JPY 02:50, Tejun Heo a??e??:

> Hello,
>
> On Tue, Jul 19, 2016 at 03:28:02PM +0800, Dou Liyang wrote:
>> In this series of patches, we are going to construct cpu <-> node mapping
>> for all possible cpus at boot time, which is a 1-1 mapping. It means the
> 1-1 mapping means that each cpu is mapped to its own private node
> which isn't the case.  Just call it a persistent mapping?

Yes, for cpus, each cpu is in a persistent node.
However, the opposite is not that.

I will modify it.

Thanks.
Dou


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
