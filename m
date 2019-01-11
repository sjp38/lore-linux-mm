Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C74D0C43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 06:14:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DEB020870
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 06:14:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DEB020870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=cn.fujitsu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 254DC8E0003; Fri, 11 Jan 2019 01:14:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2024A8E0001; Fri, 11 Jan 2019 01:14:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F0AA8E0003; Fri, 11 Jan 2019 01:14:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC2CA8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 01:14:24 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id y86so548159ita.2
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 22:14:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FYNvsLLeeEN+YpTvmUQKbfr1f/kltE4RnKD2FYI3Ia4=;
        b=XqLJ4u9CtiyvncJbPsReMyXA7Zm2OnCzDPWbw+12XzTZ3oQnH1WgT+l749OdAkaU7x
         vhc8korJJu0mOdcQAY555YyxqHdeqOcYbQUuh6IdeO/m8IV5MiKTOrnVmqQLo5rb9kpl
         +zgyqFMsOMhzWqui1ud/qWYBQPRDj/l1mNvIX0T3ZFrkLgSonsMctUhgfKk1pRAmp4LU
         FV1YtGey+iK9fu6FzIM/SkpF+FinuPqPGHYM60k5WTfHDSlpufqB6j73Lq7LYY8Qvp6y
         1/0C0SVVxXYhxJjfeIK1fC1kgVShjQZlT/l72AJFF6dk/mUCl9Oz0bG9CH5VCJMqJkug
         VH0g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of fanc.fnst@cn.fujitsu.com designates 183.91.158.132 as permitted sender) smtp.mailfrom=fanc.fnst@cn.fujitsu.com
X-Gm-Message-State: AJcUukfn8uAI2LYdRzmRAla0RImAozIJNIPL5NpH94OEDAHKAjo50NB3
	SemykTs7WWtVpp0WaZZgqb1pexmKpMu9lTsZMAi1Z2XTjKj5xSK0IaXPt/WxeovDYdn1DtFSV4V
	dc5XqZHYIQI1alBjkLDIf7TXB2saNbwU63EUQxUV+3JJdR1jRQ2Npqlm4Ecgu3zlkbA==
X-Received: by 2002:a24:8ac7:: with SMTP id v190mr383564itd.174.1547187264661;
        Thu, 10 Jan 2019 22:14:24 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7iLv75+G1bnf0LTExL2gGdAvEJtDn6jv5zskO4AK+zRuiEq+8yBQfxpXBLEhovVfLLICjB
X-Received: by 2002:a24:8ac7:: with SMTP id v190mr383547itd.174.1547187263759;
        Thu, 10 Jan 2019 22:14:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547187263; cv=none;
        d=google.com; s=arc-20160816;
        b=P8sMEhMee/37sABLXcByyqTa+bTiIAPIgH50yemQHnePfJoWm5Adup5QbGFZZGl9SL
         nxyi5WzeobGNOaJA2rjJUAZhbWK6S+B12XRAcjhvPfWzvIrDNUSXbf5gzPmsk/QjkjJC
         E8NOsrQvqHMtgfuphxMazi6kPpI5LVtf9GuTac7RvXfrngl5ql7N9lyUxUqZSfEQurUJ
         Zg0oc+FvDV94rQ1D4GcTU8WOlFWHrUGwayGfkAirS58gxxd84WipFFuxH129HmCSddv5
         Ze+RzoEKX/hHEdz1XZH3sgjuo6DI/kdHztNi3/cGsZ/h4u3koKUm2swhE/Ocl7GtgFX+
         sYLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FYNvsLLeeEN+YpTvmUQKbfr1f/kltE4RnKD2FYI3Ia4=;
        b=pMIbvxVjiPbjoPV5FLlCyQRWjgIWvP3keAQUTj9pQoD0/+7hjhc9JUVxN1fYUFUzPF
         oAr9bRAX/KTJnMm5dc2KaiyMhXkEsLFlabkGV6sOHQa1EKCH/zkn97zQAribbNDHMbUL
         ApPoA0V+QtxkOOo2jc3CGMXWDtlP/t7FY9yryVAC96Nr7jg4JDH5zP091fhGdfqdG0mw
         v+a7R56koqIDtlkcuhkV9km5YJQAu7aLRpFPl9wEwLKoxcHYAKZR0f8Gi6q3JOwYOQO4
         3HElwopV/pQF0+Fi4OpL5dgwyKhT0UEEKIUNFLHuLOvPkq++9znZRPM7pGjlbtJBln2O
         zLfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of fanc.fnst@cn.fujitsu.com designates 183.91.158.132 as permitted sender) smtp.mailfrom=fanc.fnst@cn.fujitsu.com
Received: from heian.cn.fujitsu.com (mail.cn.fujitsu.com. [183.91.158.132])
        by mx.google.com with ESMTP id l79si2385292jab.122.2019.01.10.22.14.22
        for <linux-mm@kvack.org>;
        Thu, 10 Jan 2019 22:14:23 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of fanc.fnst@cn.fujitsu.com designates 183.91.158.132 as permitted sender) client-ip=183.91.158.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of fanc.fnst@cn.fujitsu.com designates 183.91.158.132 as permitted sender) smtp.mailfrom=fanc.fnst@cn.fujitsu.com
X-IronPort-AV: E=Sophos;i="5.56,464,1539619200"; 
   d="scan'208";a="51771161"
Received: from unknown (HELO cn.fujitsu.com) ([10.167.33.5])
  by heian.cn.fujitsu.com with ESMTP; 11 Jan 2019 14:13:20 +0800
Received: from G08CNEXCHPEKD01.g08.fujitsu.local (unknown [10.167.33.80])
	by cn.fujitsu.com (Postfix) with ESMTP id 912FD4BAD914;
	Fri, 11 Jan 2019 14:13:17 +0800 (CST)
Received: from localhost.localdomain (10.167.225.56) by
 G08CNEXCHPEKD01.g08.fujitsu.local (10.167.33.89) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Fri, 11 Jan 2019 14:13:15 +0800
Date: Fri, 11 Jan 2019 14:12:21 +0800
From: Chao Fan <fanc.fnst@cn.fujitsu.com>
To: Pingfan Liu <kernelfans@gmail.com>
CC: <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin"
	<hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski
	<luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki"
	<rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Yinghai Lu
	<yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Baoquan He <bhe@redhat.com>,
	Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>, <x86@kernel.org>,
	<linux-acpi@vger.kernel.org>, <linux-mm@kvack.org>
Subject: Re: [PATCHv2 1/7] x86/mm: concentrate the code to memblock allocator
 enabled
Message-ID: <20190111061221.GB13263@localhost.localdomain>
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
 <1547183577-20309-2-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
In-Reply-To: <1547183577-20309-2-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Originating-IP: [10.167.225.56]
X-yoursite-MailScanner-ID: 912FD4BAD914.ADDB6
X-yoursite-MailScanner: Found to be clean
X-yoursite-MailScanner-From: fanc.fnst@cn.fujitsu.com
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111061221.1_Ql-vRdyfsdKhUjbh2s1topilo6iTRltDrkjTdl2mI@z>

On Fri, Jan 11, 2019 at 01:12:51PM +0800, Pingfan Liu wrote:
>This patch identifies the point where memblock alloc start. It has no
>functional.
[...]
>+#ifdef CONFIG_MEMORY_HOTPLUG
>+	/*
>+	 * Memory used by the kernel cannot be hot-removed because Linux
>+	 * cannot migrate the kernel pages. When memory hotplug is
>+	 * enabled, we should prevent memblock from allocating memory
>+	 * for the kernel.
>+	 *
>+	 * ACPI SRAT records all hotpluggable memory ranges. But before
>+	 * SRAT is parsed, we don't know about it.
>+	 *
>+	 * The kernel image is loaded into memory at very early time. We
>+	 * cannot prevent this anyway. So on NUMA system, we set any
>+	 * node the kernel resides in as un-hotpluggable.
>+	 *
>+	 * Since on modern servers, one node could have double-digit
>+	 * gigabytes memory, we can assume the memory around the kernel
>+	 * image is also un-hotpluggable. So before SRAT is parsed, just
>+	 * allocate memory near the kernel image to try the best to keep
>+	 * the kernel away from hotpluggable memory.
>+	 */
>+	if (movable_node_is_enabled())
>+		memblock_set_bottom_up(true);

Hi Pingfan,

In my understanding, 'movable_node' is based on the that memory near
kernel is considered as in the same node as kernel in high possibility.

If SRAT has been parsed early, do we still need the kernel parameter
'movable_node'? Since you have got the memory information about hot-remove,
so I wonder if it's OK to drop 'movable_node', and if memory-hotremove is
enabled, change memblock allocation according to SRAT.

If there is something wrong in my understanding, please let me know.

Thanks,
Chao Fan

>+#endif
> 	init_mem_mapping();
>+	memblock_set_current_limit(get_max_mapped());
> 
> 	idt_setup_early_pf();
> 
>@@ -1145,8 +1145,6 @@ void __init setup_arch(char **cmdline_p)
> 	 */
> 	mmu_cr4_features = __read_cr4() & ~X86_CR4_PCIDE;
> 
>-	memblock_set_current_limit(get_max_mapped());
>-
> 	/*
> 	 * NOTE: On x86-32, only from this point on, fixmaps are ready for use.
> 	 */
>-- 
>2.7.4
>
>
>


