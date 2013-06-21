Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 4F0BB6B0033
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 02:17:31 -0400 (EDT)
Message-ID: <51C3F0AC.5020006@cn.fujitsu.com>
Date: Fri, 21 Jun 2013 14:20:28 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Part1 PATCH v5 00/22] x86, ACPI, numa: Parse numa info earlier
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com> <51C3E276.8030804@zytor.com> <51C3ED76.3040900@cn.fujitsu.com> <51C3EE54.4060707@zytor.com>
In-Reply-To: <51C3EE54.4060707@zytor.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: tglx@linutronix.de, mingo@elte.hu, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Toshi Kani <toshi.kani@hp.com>

On 06/21/2013 02:10 PM, H. Peter Anvin wrote:
> On 06/20/2013 11:06 PM, Tang Chen wrote:
>>
>> Hi hpa,
>>
>> The build problem has been fixed by Yinghai.
>>
>
> Where?  I don't see anything that is obviously a fix in my inbox.
>

Yinghai resent a new version to fix the problem.
https://lkml.org/lkml/2013/6/14/561

> What about Tejun's feedback?

tj's comments were after the latest version. So we need to
restructure the patch-set.

>
> 	-hpa
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
