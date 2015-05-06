Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id C333B6B0032
	for <linux-mm@kvack.org>; Wed,  6 May 2015 18:39:24 -0400 (EDT)
Received: by wief7 with SMTP id f7so513415wie.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 15:39:24 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id q20si4456532wiv.60.2015.05.06.15.39.22
        for <linux-mm@kvack.org>;
        Wed, 06 May 2015 15:39:23 -0700 (PDT)
Date: Thu, 7 May 2015 00:39:18 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v4 4/7] mtrr, x86: Fix MTRR state checks in
 mtrr_type_lookup()
Message-ID: <20150506223917.GK22949@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
 <1427234921-19737-5-git-send-email-toshi.kani@hp.com>
 <20150506114705.GD22949@pd.tnic>
 <1430925811.23761.303.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1430925811.23761.303.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Wed, May 06, 2015 at 09:23:31AM -0600, Toshi Kani wrote:
> I have a question.  Those bits define the bit field of enabled in struct
> mtrr_state_type, which is defined in this header.  Is it OK to only move
> those definitions to other header?

I think we shouldn't expose stuff to userspace if we don't have to
because then we're stuck with it. Userspace has managed so far without
those defines so I don't see why we should export them now.

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
