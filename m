Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3F36B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 21:04:59 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id x65so21776745pfb.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 18:04:59 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id w63si5736464pfa.235.2016.02.17.18.04.56
        for <linux-mm@kvack.org>;
        Wed, 17 Feb 2016 18:04:58 -0800 (PST)
Message-ID: <56C525F9.1040107@cn.fujitsu.com>
Date: Thu, 18 Feb 2016 10:01:29 +0800
From: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 RESEND 0/5] Make cpuid <-> nodeid mapping persistent
References: <1453702100-2597-1-git-send-email-tangchen@cn.fujitsu.com>	<56A5BCDB.4090208@cn.fujitsu.com>	<56B1C504.4060905@cn.fujitsu.com> <CAJZ5v0go7tZiDkh2novJKiDmYv_ge7Y-rQLC5ohRC=qSDJ+5-Q@mail.gmail.com>
In-Reply-To: <CAJZ5v0go7tZiDkh2novJKiDmYv_ge7Y-rQLC5ohRC=qSDJ+5-Q@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: chen.tang@easystack.cn, cl@linux.com, Tejun Heo <tj@kernel.org>, Jiang Liu <jiang.liu@linux.intel.com>, mika.j.penttila@gmail.com, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J.
 Wysocki" <rjw@rjwysocki.net>, "H. Peter Anvin" <hpa@zytor.com>, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, Len Brown <len.brown@intel.com>, x86@kernel.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Rafael,

On 02/03/2016 08:02 PM, Rafael J. Wysocki wrote:
> Hi,
>
> On Wed, Feb 3, 2016 at 10:14 AM, Zhu Guihua <zhugh.fnst@cn.fujitsu.com> wrote:
>> On 01/25/2016 02:12 PM, Tang Chen wrote:
>>> Hi Rafael, Len,
>>>
>>> Would you please help to review the ACPI part of this patch-set ?
>>
>> Can anyone help to review this?
> I'm planning to look into this more thoroughly in the next few days.

Were you reviewing this ?

Thanks.

> Thanks,
> Rafael
>
>
> .
>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
