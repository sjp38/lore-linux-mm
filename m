Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id BF3DC6B0009
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 06:06:07 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id g62so21953739wme.0
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 03:06:07 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id hi5si3816670wjc.236.2016.02.10.03.06.06
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 03:06:06 -0800 (PST)
Date: Wed, 10 Feb 2016 12:06:03 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v10 4/4] x86: Create a new synthetic cpu capability for
 machine check recovery
Message-ID: <20160210110603.GE23914@pd.tnic>
References: <cover.1454618190.git.tony.luck@intel.com>
 <97426a50c5667bb81a28340b820b371d7fadb6fa.1454618190.git.tony.luck@intel.com>
 <20160207171041.GG5862@pd.tnic>
 <20160209233857.GA24348@agluck-desk.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20160209233857.GA24348@agluck-desk.sc.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, Brian Gerst <brgerst@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Tue, Feb 09, 2016 at 03:38:57PM -0800, Luck, Tony wrote:
> We use the same model number for E5 and E7 series. E.g. 63 for Haswell.
> The model_id string seems to be the only way to tell ahead of time
> whether you will get a recoverable machine check or die when you
> touch uncorrected memory.

What about MSR_IA32_PLATFORM_ID or some other MSR or register, for
example?

I.e., isn't there some other, more reliable distinction between E5 and
E7 besides the model ID?

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
