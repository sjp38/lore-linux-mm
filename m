Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6871C44043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 16:15:36 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g6so3788218pgn.11
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 13:15:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x18si4670459pge.118.2017.11.08.13.15.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 13:15:35 -0800 (PST)
Date: Wed, 8 Nov 2017 22:15:25 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [PATCH] x86/mm: Unbreak modules that rely on external
 PAGE_KERNEL availability
Message-ID: <20171108211525.4kxwj5ygg3kvfl2a@pd.tnic>
References: <nycvar.YFH.7.76.1711082103320.6470@cbobk.fhfr.pm>
 <alpine.DEB.2.20.1711082133410.1962@nanos>
 <CA+55aFz5Z8dfLp1swfOaEomH21mvCFEy=4w6L0cWska=He45FQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFz5Z8dfLp1swfOaEomH21mvCFEy=4w6L0cWska=He45FQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Jiri Kosina <jikos@kernel.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Greg KH <greg@kroah.com>

On Wed, Nov 08, 2017 at 01:09:29PM -0800, Linus Torvalds wrote:
> Generally we should export _functionality_, not data.

Right, AFAIRC, the main reason for this being an export was because if
we hid it in a function, you'd have all those function calls as part of
the _PAGE_* macros and that's just crap.

And then having an accessor too for the mask which we export anyway is
kinda silly.

But maybe there's a different, nicer solution which we missed...

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
