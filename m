Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 04FB182905
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 09:59:08 -0400 (EDT)
Received: by oiav63 with SMTP id v63so10512211oia.7
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 06:59:07 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id 184si3838077oik.112.2015.03.12.06.59.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Mar 2015 06:59:07 -0700 (PDT)
Message-ID: <1426168698.17007.385.camel@misato.fc.hp.com>
Subject: Re: [PATCH 3/3] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 12 Mar 2015 07:58:18 -0600
In-Reply-To: <20150312110333.GA6898@gmail.com>
References: <1426018997-12936-1-git-send-email-toshi.kani@hp.com>
	 <1426018997-12936-4-git-send-email-toshi.kani@hp.com>
	 <20150311070216.GD29788@gmail.com>
	 <1426092728.17007.380.camel@misato.fc.hp.com>
	 <20150312110333.GA6898@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "arnd@arndb.de" <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "Elliott, Robert (Server Storage)" <Elliott@hp.com>, "pebolle@tiscali.nl" <pebolle@tiscali.nl>

On Thu, 2015-03-12 at 11:03 +0000, Ingo Molnar wrote:
> * Toshi Kani <toshi.kani@hp.com> wrote:
> 
> > > Did it perhaps want to be the other way around:
> > > 
> > >         if (mtrr_state.have_fixed && (start < 0x1000000)) {
> > > 	...
> > >                 } else if (start < 0x100000) {
> > > 	...
> > > 
> > > or did it simply mess up the condition?
> > 
> > I think it was just paranoid to test the same condition twice...
> 
> Read the code again, it's _not_ the same condition ...

Oh, I see...  It must be a typo.  The fixed range is 0x0 to 0xFFFFF, so
it only makes sense to check with (start < 0x100000).

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
