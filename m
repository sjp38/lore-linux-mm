Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5C9716B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 15:15:56 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id p187so83244244wmp.1
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 12:15:56 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id t189si6543873wmf.48.2015.12.21.12.15.54
        for <linux-mm@kvack.org>;
        Mon, 21 Dec 2015 12:15:55 -0800 (PST)
Date: Mon, 21 Dec 2015 21:15:39 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV3 1/3] x86, ras: Add new infrastructure for machine check
 fixup tables
Message-ID: <20151221201539.GG21582@pd.tnic>
References: <cover.1450283985.git.tony.luck@intel.com>
 <2e91c18f23be90b33c2cbfff6cce6b6f50592a96.1450283985.git.tony.luck@intel.com>
 <20151221181854.GF21582@pd.tnic>
 <CAPcyv4gum9EHTa80vAcFck2RXrALDquMu2EgaTOOXBYMj2zeKQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAPcyv4gum9EHTa80vAcFck2RXrALDquMu2EgaTOOXBYMj2zeKQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Elliott@pd.tnic, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Mon, Dec 21, 2015 at 11:16:44AM -0800, Dan Williams wrote:
> I suggested we reverse the dependency and have the driver optionally
> "select MCE_KERNEL_RECOVERY".  There may be other drivers outside of
> LIBNVDIMM that want this functionality enabled.

Ah ok, makes sense.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
