Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id DB3186B00A3
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:41:26 -0400 (EDT)
Received: by mail-oi0-f47.google.com with SMTP id a141so10491988oig.34
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:41:26 -0700 (PDT)
Received: from g5t1625.atlanta.hp.com (g5t1625.atlanta.hp.com. [15.192.137.8])
        by mx.google.com with ESMTPS id w8si23736119oep.42.2014.09.10.13.41.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 13:41:26 -0700 (PDT)
Message-ID: <1410381050.28990.295.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 2/6] x86, mm, pat: Change reserve_memtype() to handle
 WT
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 10 Sep 2014 14:30:51 -0600
In-Reply-To: <5410B10A.4030207@zytor.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
		 <1410367910-6026-3-git-send-email-toshi.kani@hp.com>
		 <CALCETrXRjU3HvHogpm5eKB3Cogr5QHUvE67JOFGbOmygKYEGyA@mail.gmail.com>
	 <1410377428.28990.260.camel@misato.fc.hp.com> <5410B10A.4030207@zytor.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Wed, 2014-09-10 at 13:14 -0700, H. Peter Anvin wrote:
> On 09/10/2014 12:30 PM, Toshi Kani wrote:
> > 
> > When WT is unavailable due to the PAT errata, it does not fail but gets
> > redirected to UC-.  Similarly, when PAT is disabled, WT gets redirected
> > to UC- as well.
> > 
> 
> But on pre-PAT hardware you can still do WT.

Yes, if we manipulates the bits directly, but such code is no longer
allowed for PAT systems.  The PAT-based kernel interfaces won't work for
pre-PAT systems, and therefore requests are redirected to UC- on such
systems. 

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
