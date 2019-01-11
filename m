Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 48D188E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 15:01:13 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id p12so4891297wrt.17
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 12:01:13 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id v6si43031924wru.229.2019.01.11.12.01.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 12:01:12 -0800 (PST)
Date: Fri, 11 Jan 2019 21:01:08 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 10/25] ACPI / APEI: Tell firmware the estatus queue
 consumed the records
Message-ID: <20190111200108.GB11723@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-11-james.morse@arm.com>
 <20181211183634.GO27375@zn.tnic>
 <56cfa16b-ece4-76e0-3799-58201f8a4ff1@arm.com>
 <CABo9ajArdbYMOBGPRa185yo9MnKRb0pgS-pHqUNdNS9m+kKO-Q@mail.gmail.com>
 <20190111120322.GD4729@zn.tnic>
 <CABo9ajAk5XNBmNHRRfUb-dQzW7-UOs5826jPkrVz-8zrtMUYkg@mail.gmail.com>
 <0939c14d-de58-f21d-57a6-89bdce3bcb44@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <0939c14d-de58-f21d-57a6-89bdce3bcb44@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: Tyler Baicar <baicar.tyler@gmail.com>, Linux ACPI <linux-acpi@vger.kernel.org>, kvmarm@lists.cs.columbia.edu, arm-mail-list <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

On Fri, Jan 11, 2019 at 06:09:28PM +0000, James Morse wrote:
> We can return on ENOENT out earlier, as nothing needs doing in that case. Its
> what the GHES_TO_CLEAR spaghetti is for, we can probably move the ack thing into
> ghes_clear_estatus(), that way that thing means 'I'm done with this memory'.

That actually sounds nice and other code in the kernel already does
that: when a failure has been encountered during reading status, you
free up resources right then and there. No need for passing retvals back
and forth. And this would simplify the spaghetti. Which is something
good(tm) on its own!

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
