Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id F1CFE6B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 03:28:12 -0400 (EDT)
Received: by wief7 with SMTP id f7so104474221wie.0
        for <linux-mm@kvack.org>; Tue, 12 May 2015 00:28:12 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id dv9si1677725wib.85.2015.05.12.00.28.11
        for <linux-mm@kvack.org>;
        Tue, 12 May 2015 00:28:11 -0700 (PDT)
Date: Tue, 12 May 2015 09:28:09 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v4 7/7] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
Message-ID: <20150512072809.GA3497@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
 <1427234921-19737-8-git-send-email-toshi.kani@hp.com>
 <20150509090810.GB4452@pd.tnic>
 <1431372316.23761.440.camel@misato.fc.hp.com>
 <20150511201827.GI15636@pd.tnic>
 <1431376726.23761.471.camel@misato.fc.hp.com>
 <20150511214244.GK15636@pd.tnic>
 <1431382179.24419.12.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1431382179.24419.12.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Mon, May 11, 2015 at 04:09:39PM -0600, Toshi Kani wrote:
> There may not be any type conflict with MTRR_TYPE_INVALID.

Because...?

Let me guess: you cannot change this function to return a signed value
which is the type when positive and an error when negative?

> I will change the caller to check MTRR_TYPE_INVALID, and treat it as a
> uniform case.

That would be, of course, also wrong.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
