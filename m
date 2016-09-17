Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2773B6B0069
	for <linux-mm@kvack.org>; Sat, 17 Sep 2016 08:20:26 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y6so7341203lff.0
        for <linux-mm@kvack.org>; Sat, 17 Sep 2016 05:20:26 -0700 (PDT)
Received: from mail-lf0-x236.google.com (mail-lf0-x236.google.com. [2a00:1450:4010:c07::236])
        by mx.google.com with ESMTPS id p22si3977186lfa.94.2016.09.17.05.20.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Sep 2016 05:20:24 -0700 (PDT)
Received: by mail-lf0-x236.google.com with SMTP id y6so6306120lff.1
        for <linux-mm@kvack.org>; Sat, 17 Sep 2016 05:20:24 -0700 (PDT)
Date: Sat, 17 Sep 2016 15:20:21 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [REGRESSION] RLIMIT_DATA crashes named
Message-ID: <20160917122021.GC26044@uranus.lan>
References: <CA+55aFyfny-0F=VKKe6BCm-=fX5b08o1jPjrxTBOatiTzGdBVg@mail.gmail.com>
 <d4e15f7b-fedd-e8ff-539f-61d441b402cd@redhat.com>
 <CA+55aFzWts-dgNRuqfwHu4VeN-YcRqkZdMiRpRQ=Pg91sWJ=VQ@mail.gmail.com>
 <cone.1474065027.299244.29242.1004@monster.email-scan.com>
 <CA+55aFwPNBQePQCQ7qRmvn-nVaEn2YVsXnBFc5y1UVWExifBHw@mail.gmail.com>
 <CA+55aFy-mMfj3qj6=WMawEUGEkwnFEqB_=S6Pxx3P_c58uHW2w@mail.gmail.com>
 <1474085296.32273.95.camel@perches.com>
 <CALYGNiNuF1Ggy=DyYG32HXbnJp3Q0cX9ekQ5w2jR1M9rkKaX9A@mail.gmail.com>
 <20160917090941.GB26044@uranus.lan>
 <CALYGNiNzdsnzCZXg_-2u1Tv8+RdRFJVXa6iXY+s64=+LHr2TSA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiNzdsnzCZXg_-2u1Tv8+RdRFJVXa6iXY+s64=+LHr2TSA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Joe Perches <joe@perches.com>, Linus Torvalds <torvalds@linux-foundation.org>, Sam Varshavchik <mrsam@courier-mta.com>, Ingo Molnar <mingo@kernel.org>, Laura Abbott <labbott@redhat.com>, Brent <fix@bitrealm.com>, Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat, Sep 17, 2016 at 03:09:09PM +0300, Konstantin Khlebnikov wrote:
> >
> > Seems I don't understand the bottom unlikely...
> 
> This is gcc extrension:  https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html
> Here macro works as a function which returns bool

no, no, I know for what unlikely extension stand for.
it was just hard to obtain from without the context.
this extension implies someone calls for
if (printk_periodic()) right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
