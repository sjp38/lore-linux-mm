Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id D5FB56B0032
	for <linux-mm@kvack.org>; Wed,  6 May 2015 19:28:08 -0400 (EDT)
Received: by oica37 with SMTP id a37so20554105oic.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 16:28:08 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id c68si137866oig.120.2015.05.06.16.28.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 16:28:08 -0700 (PDT)
Message-ID: <1430953738.23761.330.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 4/7] mtrr, x86: Fix MTRR state checks in
 mtrr_type_lookup()
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 06 May 2015 17:08:58 -0600
In-Reply-To: <20150506223917.GK22949@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
	 <1427234921-19737-5-git-send-email-toshi.kani@hp.com>
	 <20150506114705.GD22949@pd.tnic>
	 <1430925811.23761.303.camel@misato.fc.hp.com>
	 <20150506223917.GK22949@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Thu, 2015-05-07 at 00:39 +0200, Borislav Petkov wrote:
> On Wed, May 06, 2015 at 09:23:31AM -0600, Toshi Kani wrote:
> > I have a question.  Those bits define the bit field of enabled in struct
> > mtrr_state_type, which is defined in this header.  Is it OK to only move
> > those definitions to other header?
> 
> I think we shouldn't expose stuff to userspace if we don't have to
> because then we're stuck with it. Userspace has managed so far without
> those defines so I don't see why we should export them now.

OK, I will move those bits definition to arch/x86/include/asm/mtrr.h.

Thanks for the clarification,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
