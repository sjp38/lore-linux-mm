Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id E21CE8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 06:46:22 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id f202so690561wme.2
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 03:46:22 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id o142si5422033wmd.1.2019.01.11.03.46.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 03:46:21 -0800 (PST)
Date: Fri, 11 Jan 2019 12:46:12 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 09/25] ACPI / APEI: Generalise the estatus queue's
 notify code
Message-ID: <20190111114612.GC4729@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-10-james.morse@arm.com>
 <20181211174449.GM27375@zn.tnic>
 <3f0f9005-f383-8a03-c7f9-15b50c099f94@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <3f0f9005-f383-8a03-c7f9-15b50c099f94@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

On Thu, Jan 10, 2019 at 06:21:21PM +0000, James Morse wrote:
> Something like:
> ghes_notify_nmi() -> in_nmi_spool_from_list(list) -> in_nmi_queue_one_entry(ghes).

Yah, but make that

ghes_notify_nmi() -> ghes_nmi_spool_from_list(list) -> ghes_nmi_queue_one_entry(ghes).

to denote it is the GHES NMI path.

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
