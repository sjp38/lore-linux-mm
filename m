Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id C45B36B0032
	for <linux-mm@kvack.org>; Tue,  5 May 2015 14:39:52 -0400 (EDT)
Received: by widdi4 with SMTP id di4so172938368wid.0
        for <linux-mm@kvack.org>; Tue, 05 May 2015 11:39:52 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id bo1si29752728wjb.27.2015.05.05.11.39.50
        for <linux-mm@kvack.org>;
        Tue, 05 May 2015 11:39:51 -0700 (PDT)
Date: Tue, 5 May 2015 20:39:47 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v4 2/7] mtrr, x86: Fix MTRR lookup to handle inclusive
 entry
Message-ID: <20150505183947.GO3910@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
 <1427234921-19737-3-git-send-email-toshi.kani@hp.com>
 <20150505171114.GM3910@pd.tnic>
 <1430847128.23761.276.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1430847128.23761.276.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Tue, May 05, 2015 at 11:32:08AM -0600, Toshi Kani wrote:
> > Ok, I'm confused. Shouldn't the inclusive:1 case be
> > 
> > 			(start:mtrr_start) (mtrr_start:mtrr_end) (mtrr_end:end)
> > 
> > ?
> > 
> > If so, this function would need more changes...
> 
> Yes, that's how it gets separated eventually.  Since *repeat is set in
> this case, the code only needs to separate the first part at a time.
> The 2nd part gets separated in the next call with the *repeat.

Aah, right, the caller is supposed to adjust the interval limits on
subsequent calls. Please reflect this in the comment because:

		*     (start:mtrr_start) (mtrr_start:end)

is misleading for inclusive:1.

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
