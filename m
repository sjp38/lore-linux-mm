Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1A8BB6B0254
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 21:08:48 -0500 (EST)
Received: by mail-lb0-f170.google.com with SMTP id k15so6742567lbg.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 18:08:48 -0800 (PST)
Received: from mail-lb0-x22e.google.com (mail-lb0-x22e.google.com. [2a00:1450:4010:c04::22e])
        by mx.google.com with ESMTPS id og3si17476836lbb.62.2016.03.02.18.08.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 18:08:46 -0800 (PST)
Received: by mail-lb0-x22e.google.com with SMTP id k15so6742251lbg.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 18:08:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1456969327-20011-1-git-send-email-zhugh.fnst@cn.fujitsu.com>
References: <1456969327-20011-1-git-send-email-zhugh.fnst@cn.fujitsu.com>
Date: Thu, 3 Mar 2016 03:08:46 +0100
Message-ID: <CAJZ5v0j1WMi5qMYoUeto8EbV2XnhZQ1j7eQ3jJtoC7h5dOxxkw@mail.gmail.com>
Subject: Re: [RESEND PATCH v5 0/5] Make cpuid <-> nodeid mapping persistent
From: "Rafael J. Wysocki" <rafael@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Cc: cl@linux.com, Tejun Heo <tj@kernel.org>, mika.j.penttila@gmail.com, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "H. Peter Anvin" <hpa@zytor.com>, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, Len Brown <len.brown@intel.com>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, chen.tang@easystack.cn, x86@kernel.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi,

On Thu, Mar 3, 2016 at 2:42 AM, Zhu Guihua <zhugh.fnst@cn.fujitsu.com> wrote:
> [Problem]
>
> cpuid <-> nodeid mapping is firstly established at boot time. And workqueue caches
> the mapping in wq_numa_possible_cpumask in wq_numa_init() at boot time.
>
> When doing node online/offline, cpuid <-> nodeid mapping is established/destroyed,
> which means, cpuid <-> nodeid mapping will change if node hotplug happens. But
> workqueue does not update wq_numa_possible_cpumask.
>

Are there any changes in this version relative to the previous one?

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
