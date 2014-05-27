Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 084606B0080
	for <linux-mm@kvack.org>; Tue, 27 May 2014 08:36:34 -0400 (EDT)
Received: by mail-la0-f51.google.com with SMTP id gf5so6410916lab.38
        for <linux-mm@kvack.org>; Tue, 27 May 2014 05:36:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g10si6127956wie.11.2014.05.27.05.36.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 May 2014 05:36:32 -0700 (PDT)
Date: Tue, 27 May 2014 14:36:29 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: lshw sees 12GB RAM but system only using 8GB
Message-ID: <20140527123629.GB22092@dhcp22.suse.cz>
References: <20140525224237.GA4869@ikrg.com>
 <20140526081414.GA16685@dhcp22.suse.cz>
 <53836B51.5020105@dougmorse.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53836B51.5020105@dougmorse.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Doug Morse <dm@dougmorse.org>
Cc: linux-mm@kvack.org

On Mon 26-05-14 11:26:57, Doug Morse wrote:
[...]
> [    0.000000] e820: BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009e7ff] usable
> [    0.000000] BIOS-e820: [mem 0x000000000009e800-0x000000000009ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000ae482fff] usable
> [    0.000000] BIOS-e820: [mem 0x00000000ae483000-0x00000000aea40fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000aea41000-0x00000000aee38fff] ACPI NVS
> [    0.000000] BIOS-e820: [mem 0x00000000aee39000-0x00000000af158fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000af159000-0x00000000af159fff] usable
> [    0.000000] BIOS-e820: [mem 0x00000000af15a000-0x00000000af35ffff] ACPI NVS
> [    0.000000] BIOS-e820: [mem 0x00000000af360000-0x00000000af7fffff] usable
> [    0.000000] BIOS-e820: [mem 0x00000000f8000000-0x00000000fbffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fec10000-0x00000000fec10fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fec20000-0x00000000fec20fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fed00000-0x00000000fed00fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fed61000-0x00000000fed70fff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fed80000-0x00000000fed8ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fef00000-0x00000000ffffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000100001000-0x000000024fffffff] usable
> [    0.000000] NX (Execute Disable) protection: active
> [    0.000000] SMBIOS 2.7 present.
> [    0.000000] DMI: Gigabyte Technology Co., Ltd. To be filled by O.E.M./970A-UD3, BIOS FC 01/28/2013
> [    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
> [    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
> [    0.000000] No AGP bridge found
> [    0.000000] e820: last_pfn = 0x250000 max_arch_pfn = 0x400000000

last_pfn (last page frame number) is 0x250000 which means that ~9GB
worth of pages can be present at maximum. The value is derived from
the e820 map provided by the kernel. So I would check the BIOS why it
doesn't tell the system about addresses above 9GB.

I am not familiar with lshw to tell you why it sees more memory.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
