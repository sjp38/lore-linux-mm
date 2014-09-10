Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4EE126B0038
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 19:35:16 -0400 (EDT)
Received: by mail-yk0-f180.google.com with SMTP id q9so3316598ykb.39
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:35:16 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id n10si13083824yhd.181.2014.09.10.16.35.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 16:35:15 -0700 (PDT)
Message-ID: <1410391481.28990.317.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 2/6] x86, mm, pat: Change reserve_memtype() to handle
 WT
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 10 Sep 2014 17:24:41 -0600
In-Reply-To: <5410C9F1.7030603@zytor.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
		 <1410367910-6026-3-git-send-email-toshi.kani@hp.com>
		 <CALCETrXRjU3HvHogpm5eKB3Cogr5QHUvE67JOFGbOmygKYEGyA@mail.gmail.com>
		 <1410377428.28990.260.camel@misato.fc.hp.com> <5410B10A.4030207@zytor.com>
		 <1410381050.28990.295.camel@misato.fc.hp.com>
		 <CALCETrUz016rDogLFTVETLh7ybVjgOMOhkL5kF2wJTLUF041xQ@mail.gmail.com>
		 <1410383484.28990.303.camel@misato.fc.hp.com>
		 <CALCETrV4DEr7tQUPCSzJMjBwgJ3-Xgcw8PFt_CCDbMoWRQ4Uug@mail.gmail.com>
		 <5410C4F7.4080704@zytor.com> <1410385673.28990.313.camel@misato.fc.hp.com>
	 <5410C9F1.7030603@zytor.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Wed, 2014-09-10 at 15:00 -0700, H. Peter Anvin wrote:
> On 09/10/2014 02:47 PM, Toshi Kani wrote:
> >>
> >> Yes.  Don't think of it as PAT vs non-PAT.  Think of it as a specific
> >> set of cache types available on different processors.  The fact that you
> >> may have to frob an MSR to initialize it is almost trivial in comparison.
> > 
> > Right.
> > 
> 
> In that sense the Xen "fixed PAT" fits right in.

Got it. Nicely simplified. :) 

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
