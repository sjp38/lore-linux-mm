Received: by ug-out-1314.google.com with SMTP id c2so1096397ugf
        for <linux-mm@kvack.org>; Sun, 29 Jul 2007 10:19:38 -0700 (PDT)
Message-ID: <2c0942db0707291019q14f309d0jab3bf083aa37d707@mail.gmail.com>
Date: Sun, 29 Jul 2007 10:19:38 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
In-Reply-To: <46ACC76A.3080303@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	 <46AC4B97.5050708@gmail.com>
	 <20070729141215.08973d54@the-village.bc.nu>
	 <46AC9F2C.8090601@gmail.com>
	 <2c0942db0707290758p39fef2e8o68d67bec5c7ba6ab@mail.gmail.com>
	 <46ACAB45.6080307@gmail.com>
	 <2c0942db0707290820r2e31f40flb51a43846169a752@mail.gmail.com>
	 <46ACB40C.2040908@gmail.com>
	 <2c0942db0707290904n4356582dt91ab96b77db1e84e@mail.gmail.com>
	 <46ACC76A.3080303@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, david@lang.hm, Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 7/29/07, Rene Herman <rene.herman@gmail.com> wrote:
> On 07/29/2007 06:04 PM, Ray Lee wrote:
> >> I am very aware of the costs of seeks (on current magnetic media).
> >
> > Then perhaps you can just take it on faith -- log structured layouts
> > are designed to help minimize seeks, read and write.
>
> I am particularly bad at faith. Let's take that stupid program that I posted:

You only think you are :-). I'm sure there are lots of things you have
faith in. Gravity, for example :-).

> The program is not a real-world issue and if you do not consider it a useful
> boundary condition either (okay I guess), how would log structured swap help
> if I just assume I have plenty of free swap to begin with?

Is that generally the case on your systems? Every linux system I've
run, regardless of RAM, has always pushed things out to swap. And once
there's something already in swap, you now have a packing problem when
you want to swap something else out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
