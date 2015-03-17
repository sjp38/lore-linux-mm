Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 00A2C6B0032
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 14:24:52 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so16717982pdb.3
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 11:24:52 -0700 (PDT)
Received: from lxorguk.ukuu.org.uk (7.3.c.8.2.a.e.f.f.f.8.1.0.3.2.0.9.6.0.7.2.3.f.b.0.b.8.0.1.0.0.2.ip6.arpa. [2001:8b0:bf32:7069:230:18ff:fea2:8c37])
        by mx.google.com with ESMTPS id pq9si30827033pdb.223.2015.03.17.11.24.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 11:24:52 -0700 (PDT)
Date: Tue, 17 Mar 2015 17:58:59 +0000
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: rowhammer and pagemap (was Re: [RFC, PATCH] pagemap: do not
 leak physical addresses to non-privileged userspace)
Message-ID: <20150317175859.1d9555fc@lxorguk.ukuu.org.uk>
In-Reply-To: <20150317111653.GA23711@amd>
References: <1425935472-17949-1-git-send-email-kirill@shutemov.name>
	<20150316211122.GD11441@amd>
	<CAL82V5O6awBrpj8uf2_cEREzZWPfjLfqPtRbHEd5_zTkRLU8Sg@mail.gmail.com>
	<CALCETrU8SeOTSexLOi36sX7Smwfv0baraK=A3hq8twoyBN7NBg@mail.gmail.com>
	<20150317111653.GA23711@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Andy Lutomirski <luto@amacapital.net>, Mark Seaborn <mseaborn@chromium.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>

> > Can we just try getting rid of it except with global CAP_SYS_ADMIN.
> > 
> > (Hmm.  Rowhammer attacks targeting SMRAM could be interesting.)
> 

CAP_SYS_RAWIO is the protection for "can achieve anything". If you have
CAP_SYS_RAWIO you can attain any other capability, the reverse _should_
not be true.

> > The Intel people I asked last week weren't confident.  For one thing,
> > I fully expect that rowhammer can be exploited using only reads and
> > writes with some clever tricks involving cache associativity.  I don't
> > think there are any fully-associative caches, although the cache
> > replacement algorithm could make the attacks interesting.
> 
> We should definitely get Intel/AMD to disable CLFLUSH, then.

I doubt that would work, because you'd have to fix up all the faults from
userspace in things like graphics and video. Whether it is possible to
make the microcode do other accesses and delays I have no idea - but
that might also be quite horrible.

A serious system should be using ECC memory anyway. and on things like
shared boxes it is probably not a root compromise that is the worst case
scenario but subtle undetected corruption of someone elses data sets.

That's what ECC already exists to protect against whether its from flawed
memory and rowhammer or just a vindictive passing cosmic ray.

Alan


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
