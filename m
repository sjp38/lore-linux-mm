Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 29B4F6B026E
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 09:05:07 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id c41so9384176otc.18
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 06:05:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y16sor4666817oia.312.2017.12.04.06.05.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Dec 2017 06:05:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171204112855.GA6373@samekh>
References: <cover.1511433386.git.ar@linux.vnet.ibm.com> <4e21a27570f665793debf167c8567c6752116d0a.1511433386.git.ar@linux.vnet.ibm.com>
 <20171129004913.GB1469@linux-l9pv.suse> <20171129015229.GD1469@linux-l9pv.suse>
 <20171204112855.GA6373@samekh>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Mon, 4 Dec 2017 15:05:05 +0100
Message-ID: <CAJZ5v0hZPtKvBBr3mRhpE5zbWVYYL6To8CWrf_drwWXQ=ohRjQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/5] mm: memory_hotplug: Remove assumption on memory
 state before hotremove
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Reale <ar@linux.vnet.ibm.com>
Cc: joeyli <jlee@suse.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, Mark Rutland <mark.rutland@arm.com>, scott.branden@broadcom.com, Will Deacon <will.deacon@arm.com>, qiuxishi@huawei.com, Catalin Marinas <catalin.marinas@arm.com>, Michal Hocko <mhocko@suse.com>, Rafael Wysocki <rafael.j.wysocki@intel.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

On Mon, Dec 4, 2017 at 12:28 PM, Andrea Reale <ar@linux.vnet.ibm.com> wrote:
> Hi Joey,
>
> and thanks for your comments. Response inline:
>

[cut]

>>
>> So, the BUG() is useful to capture state issue in memory subsystem. But, I
>> understood your concern about the two steps offline/remove from userland.
>>
>> Maybe we should move the BUG() to somewhere but not just remove it. Or if
>> we think that the BUG() is too intense, at least we should print out a error
>> message, and ACPI should checks the return value from subsystem to
>> interrupt memory-hotplug process.
>
> In this patchset, BUG() is moved to acpi_memory_remove_memory(),
> the caller of arch_remove_memory(). However, I agree with Michal, that
> we should not BUG() here but rather halt the hotremove process and print
> some errors.
> Is there any state in ACPI that should be undone in case of hotremove
> errors or we can just stop the process "halfway"?

I have to recall a couple of things before answering this question, so
that may take some time.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
