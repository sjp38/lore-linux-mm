Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id B81566B000A
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 12:30:23 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id i5so1967736otf.8
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 09:30:23 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t200si787763oih.27.2018.02.16.09.30.22
        for <linux-mm@kvack.org>;
        Fri, 16 Feb 2018 09:30:22 -0800 (PST)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [bug?] mallocstress poor performance with THP on arm64 system
References: <1523287676.1950020.1518648233654.JavaMail.zimbra@redhat.com>
	<1847959563.1954032.1518649501357.JavaMail.zimbra@redhat.com>
	<20180215090246.qrsnncq3ajtbdlfy@node.shutemov.name>
Date: Fri, 16 Feb 2018 17:30:19 +0000
In-Reply-To: <20180215090246.qrsnncq3ajtbdlfy@node.shutemov.name> (Kirill
	A. Shutemov's message of "Thu, 15 Feb 2018 12:02:46 +0300")
Message-ID: <87a7w84zbo.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org, lwoodman <lwoodman@redhat.com>, Rafael Aquini <aquini@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

Hi Kirill,

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Wed, Feb 14, 2018 at 06:05:01PM -0500, Jan Stancek wrote:
>> Hi,
>> 
>> mallocstress[1] LTP testcase takes ~5+ minutes to complete
>> on some arm64 systems (e.g. 4 node, 64 CPU, 256GB RAM):
>>  real    7m58.089s
>>  user    0m0.513s
>>  sys     24m27.041s
>> 
>> But if I turn off THP ("transparent_hugepage=never") it's a lot faster:
>>  real    0m4.185s
>>  user    0m0.298s
>>  sys     0m13.954s
>> 
>
> It's multi-threaded workload. My *guess* is that poor performance is due
> to lack of ARCH_ENABLE_SPLIT_PMD_PTLOCK support on arm64.

In this instance I think the latency is due to the large size of PMD
hugepages and THP=always. But split PMD locks seem like a useful feature
to have for large core count systems.

I'll have a go at enabling this for arm64.

Thanks,
Punit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
