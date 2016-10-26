Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 594A56B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 19:07:30 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b80so20350198wme.5
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 16:07:30 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id fc4si5198959wjd.5.2016.10.26.16.07.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 16:07:29 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 85AAD1C1812
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 00:07:28 +0100 (IST)
Date: Thu, 27 Oct 2016 00:07:26 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
Message-ID: <20161026230726.GF2699@techsingularity.net>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com>
 <CALCETrUt+4ojyscJT1AFN5Zt3mKY0rrxcXMBOUUJzzLMWXFXHg@mail.gmail.com>
 <CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com>
 <CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com>
 <20161026203158.GD2699@techsingularity.net>
 <CA+55aFy21NqcYTeLVVz4x4kfQ7A+o4HEv7srone6ppKAjCwn7g@mail.gmail.com>
 <20161026220339.GE2699@techsingularity.net>
 <CA+55aFwgZ6rUL2-KD7A38xEkALJcvk8foT2TBjLrvy8caj7k9w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFwgZ6rUL2-KD7A38xEkALJcvk8foT2TBjLrvy8caj7k9w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 26, 2016 at 03:09:41PM -0700, Linus Torvalds wrote:
> On Wed, Oct 26, 2016 at 3:03 PM, Mel Gorman <mgorman@techsingularity.net> wrote:
> >
> > To be clear, are you referring to PeterZ's patch that avoids the lookup? If
> > so, I see your point.
> 
> Yup, that's the one. I think you tested it. In fact, I'm sure you did,
> because I remember seeing performance numbers from  you ;)
> 

Yeah and the figures were fine. IIRC, 32-bit support was the main thing
that was missing but who cares, 32-bit is not going to have the NUMA issues
in any way that matters.

> So yes, I'd expect my patch on its own to quite possibly regress on
> NUMA systems (although I wonder how much),

I doubt it's a lot. Even if it does, it's doesn't matter because it's a
functional fix.

> but I consider PeterZ's
> patch the fix to that, so I wouldn't worry about it.
> 

Agreed. Peter, do you plan to finish that patch?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
