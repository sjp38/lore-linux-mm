Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 11EE56B0254
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 05:44:10 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id n186so158543280wmn.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 02:44:10 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id w2si1009577wjf.153.2015.12.15.02.44.08
        for <linux-mm@kvack.org>;
        Tue, 15 Dec 2015 02:44:08 -0800 (PST)
Date: Tue, 15 Dec 2015 11:44:02 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV2 1/3] x86, ras: Add new infrastructure for machine check
 fixup tables
Message-ID: <20151215104402.GC25973@pd.tnic>
References: <cover.1449861203.git.tony.luck@intel.com>
 <456153d09e85f2f139020a051caed3ca8f8fca73.1449861203.git.tony.luck@intel.com>
 <20151212101142.GA3867@pd.tnic>
 <20151215010059.GA17353@agluck-desk.sc.intel.com>
 <20151215094653.GA25973@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20151215094653.GA25973@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Tue, Dec 15, 2015 at 10:46:53AM +0100, Borislav Petkov wrote:
> I think what is more important is that this should be in the
> x86-specific linker script, not in the generic one.

And related to that, I think all those additions to kernel/extable.c
should be somewhere in arch/x86/ and not in generic code.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
