Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id F19476B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 05:51:50 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 56so37147160wrx.5
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 02:51:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s24si461604wra.76.2017.06.14.02.51.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 02:51:49 -0700 (PDT)
Date: Wed, 14 Jun 2017 11:51:39 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC 08/11] x86/mm: Add nopcid to turn off PCID
Message-ID: <20170614095139.nk7nf4oilc36mi2b@pd.tnic>
References: <cover.1496701658.git.luto@kernel.org>
 <d4eafd524ee51d003d7f7302d5e4e44dc4919e08.1496701658.git.luto@kernel.org>
 <87wp8pol4u.fsf@firstfloor.org>
 <CALCETrV-Wkqt89fJmjgK_BAdmzvXG8Vr1aTXDSnLRPO1NhwYYA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALCETrV-Wkqt89fJmjgK_BAdmzvXG8Vr1aTXDSnLRPO1NhwYYA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <andi@firstfloor.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>

On Tue, Jun 13, 2017 at 09:52:03PM -0700, Andy Lutomirski wrote:
> It is.  OTOH, there are lots of noxyz options, and they're easier to
> type and to remember.  Borislav?  Sometime I wonder whether we should
> autogenerate noxyz options from the capflags table.

Maybe.

Although, last time hpa said that all those old chicken bits can simply
be removed now that they're not really needed anymore. I even had a
patch somewhere but then something more important happened...

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
