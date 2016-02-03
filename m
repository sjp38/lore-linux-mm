Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f48.google.com (mail-lf0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id DBB866B0005
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 07:02:40 -0500 (EST)
Received: by mail-lf0-f48.google.com with SMTP id 78so12127545lfy.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 04:02:40 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id 38si3780512lfu.151.2016.02.03.04.02.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 04:02:39 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id e36so604950lfi.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 04:02:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56B1C504.4060905@cn.fujitsu.com>
References: <1453702100-2597-1-git-send-email-tangchen@cn.fujitsu.com>
	<56A5BCDB.4090208@cn.fujitsu.com>
	<56B1C504.4060905@cn.fujitsu.com>
Date: Wed, 3 Feb 2016 13:02:38 +0100
Message-ID: <CAJZ5v0go7tZiDkh2novJKiDmYv_ge7Y-rQLC5ohRC=qSDJ+5-Q@mail.gmail.com>
Subject: Re: [PATCH v5 RESEND 0/5] Make cpuid <-> nodeid mapping persistent
From: "Rafael J. Wysocki" <rafael@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Cc: chen.tang@easystack.cn, cl@linux.com, Tejun Heo <tj@kernel.org>, Jiang Liu <jiang.liu@linux.intel.com>, mika.j.penttila@gmail.com, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "H. Peter Anvin" <hpa@zytor.com>, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, Len Brown <len.brown@intel.com>, x86@kernel.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi,

On Wed, Feb 3, 2016 at 10:14 AM, Zhu Guihua <zhugh.fnst@cn.fujitsu.com> wrote:
>
> On 01/25/2016 02:12 PM, Tang Chen wrote:
>>
>> Hi Rafael, Len,
>>
>> Would you please help to review the ACPI part of this patch-set ?
>
>
> Can anyone help to review this?

I'm planning to look into this more thoroughly in the next few days.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
