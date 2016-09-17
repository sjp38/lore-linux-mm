Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7896B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 20:04:59 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 184so104220455ity.1
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 17:04:59 -0700 (PDT)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id g9si12639100otb.239.2016.09.16.17.04.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 17:04:58 -0700 (PDT)
Received: by mail-oi0-x22b.google.com with SMTP id m11so130157751oif.1
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 17:04:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwPNBQePQCQ7qRmvn-nVaEn2YVsXnBFc5y1UVWExifBHw@mail.gmail.com>
References: <33304dd8-8754-689d-11f3-751833b4a288@redhat.com>
 <CA+55aFyfny-0F=VKKe6BCm-=fX5b08o1jPjrxTBOatiTzGdBVg@mail.gmail.com>
 <d4e15f7b-fedd-e8ff-539f-61d441b402cd@redhat.com> <CA+55aFzWts-dgNRuqfwHu4VeN-YcRqkZdMiRpRQ=Pg91sWJ=VQ@mail.gmail.com>
 <cone.1474065027.299244.29242.1004@monster.email-scan.com> <CA+55aFwPNBQePQCQ7qRmvn-nVaEn2YVsXnBFc5y1UVWExifBHw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 16 Sep 2016 17:04:57 -0700
Message-ID: <CA+55aFy-mMfj3qj6=WMawEUGEkwnFEqB_=S6Pxx3P_c58uHW2w@mail.gmail.com>
Subject: Re: [REGRESSION] RLIMIT_DATA crashes named
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Varshavchik <mrsam@courier-mta.com>, Ingo Molnar <mingo@kernel.org>, Joe Perches <joe@perches.com>
Cc: Laura Abbott <labbott@redhat.com>, Brent <fix@bitrealm.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Christian Borntraeger <borntraeger@de.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Sep 16, 2016 at 4:58 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Here's a totally untested patch. What do people say?

Heh. It looks like "pr_xyz_once()" is used in places that haven't
included "ratelimit.h", so this doesn't actually build for everything.

But I guess as a concept patch it's not hard to understand, even if
the implementation needs a bit of tweaking.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
