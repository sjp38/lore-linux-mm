Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 607DD6B0069
	for <linux-mm@kvack.org>; Sat, 17 Sep 2016 00:08:21 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g22so116487438ioj.1
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 21:08:21 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0248.hostedemail.com. [216.40.44.248])
        by mx.google.com with ESMTPS id 130si14543797its.84.2016.09.16.21.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 21:08:20 -0700 (PDT)
Message-ID: <1474085296.32273.95.camel@perches.com>
Subject: Re: [REGRESSION] RLIMIT_DATA crashes named
From: Joe Perches <joe@perches.com>
Date: Fri, 16 Sep 2016 21:08:16 -0700
In-Reply-To: <CA+55aFy-mMfj3qj6=WMawEUGEkwnFEqB_=S6Pxx3P_c58uHW2w@mail.gmail.com>
References: <33304dd8-8754-689d-11f3-751833b4a288@redhat.com>
	 <CA+55aFyfny-0F=VKKe6BCm-=fX5b08o1jPjrxTBOatiTzGdBVg@mail.gmail.com>
	 <d4e15f7b-fedd-e8ff-539f-61d441b402cd@redhat.com>
	 <CA+55aFzWts-dgNRuqfwHu4VeN-YcRqkZdMiRpRQ=Pg91sWJ=VQ@mail.gmail.com>
	 <cone.1474065027.299244.29242.1004@monster.email-scan.com>
	 <CA+55aFwPNBQePQCQ7qRmvn-nVaEn2YVsXnBFc5y1UVWExifBHw@mail.gmail.com>
	 <CA+55aFy-mMfj3qj6=WMawEUGEkwnFEqB_=S6Pxx3P_c58uHW2w@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Sam Varshavchik <mrsam@courier-mta.com>, Ingo Molnar <mingo@kernel.org>
Cc: Laura Abbott <labbott@redhat.com>, Brent <fix@bitrealm.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Christian Borntraeger <borntraeger@de.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, 2016-09-16 at 17:040700, Linus Torvalds wrote:
> On Fri, Sep 16, 2016 at 4:58 PM, Linus Torvalds <torvalds@linux-foundation.org> wrote:
> > Here's a totally untested patch. What do people say?
> Heh. It looks like "pr_xyz_once()" is used in places that haven't
> included "ratelimit.h", so this doesn't actually build for everything.
> But I guess as a concept patch it's not hard to understand, even if
> the implementation needs a bit of tweaking.

do_just_once just isn't a good name for a global
rate limited mechanism that does something very
different than the name.

Maybe allow_once_per_ratelimit or the like

There could be an equivalent do_once

https://lkml.org/lkml/2009/5/22/3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
