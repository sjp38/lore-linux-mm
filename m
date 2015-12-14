Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id CDC1D6B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 17:28:05 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id n186so68577911wmn.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:28:05 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id xw2si48879112wjc.40.2015.12.14.14.28.04
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 14:28:04 -0800 (PST)
Date: Mon, 14 Dec 2015 23:27:59 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV2 1/3] x86, ras: Add new infrastructure for machine check
 fixup tables
Message-ID: <20151214222759.GF10520@pd.tnic>
References: <cover.1449861203.git.tony.luck@intel.com>
 <456153d09e85f2f139020a051caed3ca8f8fca73.1449861203.git.tony.luck@intel.com>
 <20151212101142.GA3867@pd.tnic>
 <CAOxpaSX5SH7T2AqvGoFDtEWKc9k_-77gbQXQd7FYQZ-Ep2kRhA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAOxpaSX5SH7T2AqvGoFDtEWKc9k_-77gbQXQd7FYQZ-Ep2kRhA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <zwisler@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, Dec 14, 2015 at 10:58:45AM -0700, Ross Zwisler wrote:
> With this code if CONFIG_MCE_KERNEL_RECOVERY isn't defined you'll get
> a compiler error that the function doesn't have a return statement,
> right?  I think we need an #else to return NULL, or to have the #ifdef
> encompass the whole function definition as it was in Tony's version.

Right, correct.

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
