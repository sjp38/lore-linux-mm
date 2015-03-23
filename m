Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 126016B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 15:45:25 -0400 (EDT)
Received: by obbgg8 with SMTP id gg8so131389025obb.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 12:45:24 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id k1si1071310oed.5.2015.03.23.12.45.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 12:45:24 -0700 (PDT)
Message-ID: <1427138833.31093.24.camel@misato.fc.hp.com>
Subject: Re: [PATCH v3 4/5] mtrr, x86: Clean up mtrr_type_lookup()
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 23 Mar 2015 13:27:13 -0600
In-Reply-To: <B4C2A151-B238-487F-942B-A550201FBAAD@hp.com>
References: <1426282421-25385-1-git-send-email-toshi.kani@hp.com>
	 <1426282421-25385-5-git-send-email-toshi.kani@hp.com>
	,<20150316075821.GA16062@gmail.com>
	 <B4C2A151-B238-487F-942B-A550201FBAAD@hp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "Elliott, Robert (Server
 Storage)" <Elliott@hp.com>, "pebolle@tiscali.nl" <pebolle@tiscali.nl>

On Mon, 2015-03-16 at 21:24 +0000, Kani, Toshimitsu wrote:
> > On Mar 16, 2015, at 3:58 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >> * Toshi Kani <toshi.kani@hp.com> wrote:
 :
> 
> >> +    if (!(mtrr_state.have_fixed) ||
> >> +        !(mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED))
> > 
> > Btw., can MTRR_STATE_MTRR_FIXED_ENABLED ever be set in 
> > mtrr_state.enabled, without mtrr_state.have_fixed being set?
> 
> Yes, I believe the arch allows the fixed entries disabled
> while MTRRs are enabled.  I expect the most of systems 
> implement the fixed entries, though.

Sorry, I noticed I had mis-read your question before...

No, MTRR_STATE_MTRR_FIXED_ENABLED may not be set without
mtrr_state.have_fixed being set.  mtrr_state.have_fixed indicates if the
CPU supports MTRR fixed ranges.  So, they can be only enabled when the
CPU has ones.

> > AFAICS get_mtrr_state() will only ever fill in mtrr_state with fixed 
> > MTRRs if mtrr_state.have_fixed != 0 - but I might be mis-reading the 
> > (rather convoluted) flow of code ...
> 
> I will check the code next week.

Yes, you are right that get_mtrr_state() only fills in
mtrr_state.fixed_ranges[] when mtrr_state.have_fixed is set.  This is
because the MSRs containing the fixed ranges are only valid when this
flag is set. 

Thanks,
-Toshi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
