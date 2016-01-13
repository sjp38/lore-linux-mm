Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 989CA828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 23:55:34 -0500 (EST)
Received: by mail-io0-f169.google.com with SMTP id g73so211763861ioe.3
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 20:55:34 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id s37si1959812ioe.199.2016.01.12.20.55.33
        for <linux-mm@kvack.org>;
        Tue, 12 Jan 2016 20:55:33 -0800 (PST)
Message-ID: <5695D906.2030405@cn.fujitsu.com>
Date: Wed, 13 Jan 2016 12:56:38 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] x86, acpi, cpu-hotplug: Set persistent cpuid <->
 nodeid mapping when booting.
References: <1452140425-16577-1-git-send-email-tangchen@cn.fujitsu.com> <1452140425-16577-6-git-send-email-tangchen@cn.fujitsu.com> <20160108191305.GA1898@mtj.duckdns.org>
In-Reply-To: <20160108191305.GA1898@mtj.duckdns.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>


On 01/09/2016 03:13 AM, Tejun Heo wrote:
> Hello, Tang.
>
> On Thu, Jan 07, 2016 at 12:20:25PM +0800, Tang Chen wrote:
>> From: Gu Zheng <guz.fnst@cn.fujitsu.com>
>>
>> This patch finishes step 4.
> This doesn't help people trying to read the patch.  If you wanna say
> it's one of the steps of something, you also need to say what the
> steps are.  No need to duplicate the whole thing but a short summary
> would be helpful.

Sure. Thx.

>
>> This patch set the persistent cpuid <-> nodeid mapping for all enabled/disabled
>> processors at boot time via an additional acpi namespace walk for processors.
> So, the patchset generally looks good to me although I'm not too
> familiar with acpi.  Rafael, Len, what do you think?
>
> Thanks.
>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
