Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79ED66B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 20:56:54 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h186so68919772pfg.3
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 17:56:54 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id s6si116429pay.219.2016.07.19.17.56.53
        for <linux-mm@kvack.org>;
        Tue, 19 Jul 2016 17:56:53 -0700 (PDT)
Subject: Re: [PATCH v8 7/7] Provide the interface to validate the proc_id
 which they give
References: <1468913288-16605-1-git-send-email-douly.fnst@cn.fujitsu.com>
 <1468913288-16605-8-git-send-email-douly.fnst@cn.fujitsu.com>
 <20160719185320.GN3078@mtj.duckdns.org>
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Message-ID: <438ce500-ec84-9f55-0422-d033a1f4590f@cn.fujitsu.com>
Date: Wed, 20 Jul 2016 08:55:11 +0800
MIME-Version: 1.0
In-Reply-To: <20160719185320.GN3078@mtj.duckdns.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, rafael@kernel.org, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org



a?? 2016a1'07ae??20ae?JPY 02:53, Tejun Heo a??e??:
> On Tue, Jul 19, 2016 at 03:28:08PM +0800, Dou Liyang wrote:
>> When we want to identify whether the proc_id is unreasonable or not, we
>> can call the "acpi_processor_validate_proc_id" function. It will search
>> in the duplicate IDs. If we find the proc_id in the IDs, we return true
>> to the call function. Conversely, false represents available.
>>
>> When we establish all possible cpuid <-> nodeid mapping, we will use the
>> proc_id from ACPI table.
>>
>> We do validation when we get the proc_id. If the result is true, we will
>> stop the mapping.
> The patch title probably should include "acpi:" header.  I can't tell
> much about the specifics of the acpi changes but I think this is the
> right approach for handling cpu hotplugs.

I will change the title in the next version.

Thanks.
> Thanks.
>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
