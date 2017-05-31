Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 60E806B02F4
	for <linux-mm@kvack.org>; Wed, 31 May 2017 17:45:35 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n75so28743418pfh.0
        for <linux-mm@kvack.org>; Wed, 31 May 2017 14:45:35 -0700 (PDT)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id g92si25861314plg.80.2017.05.31.14.45.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 14:45:33 -0700 (PDT)
Received: by mail-pf0-x233.google.com with SMTP id 9so18594622pfj.1
        for <linux-mm@kvack.org>; Wed, 31 May 2017 14:45:33 -0700 (PDT)
Date: Wed, 31 May 2017 14:45:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] compiler, clang: suppress warning for unused static
 inline functions
In-Reply-To: <CAD=FV=Xi7NjDjsdwGP=GGS9p=uUpqZa7S=irNOFmhfD1F3kWZQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.10.1705311436490.82977@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1705241400510.49680@chino.kir.corp.google.com> <20170524212229.GR141096@google.com> <20170524143205.cae1a02ab2ad7348c1a59e0c@linux-foundation.org> <CAD=FV=XjC3M=EWC=rtcbTUR6e1F2cfuYvqL53F9H7tdMAOALNw@mail.gmail.com>
 <alpine.DEB.2.10.1705301704370.10695@chino.kir.corp.google.com> <CAD=FV=Xi7NjDjsdwGP=GGS9p=uUpqZa7S=irNOFmhfD1F3kWZQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Doug Anderson <dianders@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthias Kaehlcke <mka@chromium.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mark Brown <broonie@kernel.org>, Ingo Molnar <mingo@kernel.org>, David Miller <davem@davemloft.net>

On Wed, 31 May 2017, Doug Anderson wrote:

> > Again, I defer to maintainers like Andrew and Ingo who have to deal with
> > an enormous amount of patches on how they would like to handle it; I don't
> > think myself or anybody else who doesn't deal with a large number of
> > patches should be mandating how it's handled.
> >
> > For reference, the patchset that this patch originated from added 8 lines
> > and removed 1, so I disagree that this cleans anything up; in reality, it
> > obfuscates the code and makes the #ifdef nesting more complex.
> 
> As Matthias said, let's not argue about ifdeffs and instead talk about
> adding "maybe unused".  100% of these cases _can_ be solved by adding
> "maybe unused".  Then, if a maintainer thinks that an ifdef is cleaner
> / better in a particular case, we can use an ifdef in that case.
> 
> Do you believe that adding "maybe unused" tags significantly uglifies
> the code?  I personally find them documenting.
> 

But then you've eliminated the possibility of finding dead code again, 
which is the only point to the warning :)  So now we have patches going to 
swamped maintainers to add #ifdef's, more LOC, and now patches to sprinkle 
__maybe_unused throughout the code to not increase LOC in select areas but 
then we can't find dead code again.

My suggestion is to match gcc behavior and if anybody is in the business 
of cleaning up truly dead code, send patches.  Tools exist to do this 
outside of relying on a minority compiler during compilation.  Otherwise, 
this is simply adding more burden to already swamped maintainers to 
annotate every single static inline function that clang complains about.  
I'd prefer to let them decide and this will be the extent of my 
participation in this thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
