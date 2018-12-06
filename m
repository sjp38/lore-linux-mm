Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B0066B7AD7
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 11:18:51 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id 73so389740oth.9
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 08:18:51 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d14si287056oti.315.2018.12.06.08.18.50
        for <linux-mm@kvack.org>;
        Thu, 06 Dec 2018 08:18:50 -0800 (PST)
Date: Thu, 6 Dec 2018 16:18:45 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v7 24/25] firmware: arm_sdei: Add ACPI GHES registration
 helper
Message-ID: <20181206161844.GO54495@arrakis.emea.arm.com>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-25-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203180613.228133-25-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, Rafael Wysocki <rjw@rjwysocki.net>, Tony Luck <tony.luck@intel.com>, Fan Wu <wufan@codeaurora.org>, Xie XiuQi <xiexiuqi@huawei.com>, Marc Zyngier <marc.zyngier@arm.com>, Will Deacon <will.deacon@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Dongjiu Geng <gengdongjiu@huawei.com>, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, Len Brown <lenb@kernel.org>

On Mon, Dec 03, 2018 at 06:06:12PM +0000, James Morse wrote:
> APEI's Generic Hardware Error Source structures do not describe
> whether the SDEI event is shared or private, as this information is
> discoverable via the API.
> 
> GHES needs to know whether an event is normal or critical to avoid
> sharing locks or fixmap entries, but GHES shouldn't have to know about
> the SDEI API.
> 
> Add a helper to register the GHES using the appropriate normal or
> critical callback.
> 
> Signed-off-by: James Morse <james.morse@arm.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
