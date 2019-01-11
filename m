Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 920048E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 12:45:37 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id e17so4894781wrw.13
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 09:45:37 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id g10si7306417wrm.253.2019.01.11.09.45.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 09:45:36 -0800 (PST)
Date: Fri, 11 Jan 2019 18:45:32 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 10/25] ACPI / APEI: Tell firmware the estatus queue
 consumed the records
Message-ID: <20190111174532.GI4729@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-11-james.morse@arm.com>
 <20181211183634.GO27375@zn.tnic>
 <56cfa16b-ece4-76e0-3799-58201f8a4ff1@arm.com>
 <CABo9ajArdbYMOBGPRa185yo9MnKRb0pgS-pHqUNdNS9m+kKO-Q@mail.gmail.com>
 <20190111120322.GD4729@zn.tnic>
 <CABo9ajAk5XNBmNHRRfUb-dQzW7-UOs5826jPkrVz-8zrtMUYkg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CABo9ajAk5XNBmNHRRfUb-dQzW7-UOs5826jPkrVz-8zrtMUYkg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tyler Baicar <baicar.tyler@gmail.com>
Cc: James Morse <james.morse@arm.com>, Linux ACPI <linux-acpi@vger.kernel.org>, kvmarm@lists.cs.columbia.edu, arm-mail-list <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

On Fri, Jan 11, 2019 at 10:32:23AM -0500, Tyler Baicar wrote:
> The kernel would have no way of knowing what to do here.

What do you mean, there's no way of knowing what to do? It needs to
clear registers so that the next error can get reported properly.

Or of the status read failed and it doesn't need to do anything, then it
shouldn't.

Whatever it is, the kernel either needs to do something in the error
case to clean up, or nothing if the firmware doesn't need anything done
in the error case; *or* ack the error in the success case.

This should all be written down somewhere in that GHES v2
spec/doc/writeup whatever, explaining what the OS is supposed to do to
signal the error has been read by the OS.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
