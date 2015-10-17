Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6845782F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 22:23:26 -0400 (EDT)
Received: by pabws5 with SMTP id ws5so5778424pab.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 19:23:26 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id bi5si33486261pbc.38.2015.10.16.19.23.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 19:23:25 -0700 (PDT)
Received: by pabws5 with SMTP id ws5so5778304pab.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 19:23:25 -0700 (PDT)
Date: Sat, 17 Oct 2015 11:22:08 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [RFC][PATCH 0/8] introduce slabinfo extended mode
Message-ID: <20151017022208.GA1757@swordfish>
References: <1444907673-8863-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20151016153544.2d70713d6a0f2afd5744fa00@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151016153544.2d70713d6a0f2afd5744fa00@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On (10/16/15 15:35), Andrew Morton wrote:
> On Thu, 15 Oct 2015 20:14:25 +0900 Sergey Senozhatsky <sergey.senozhatsky@gmail.com> wrote:
> 
> > Add 'extended' slabinfo mode that provides additional information:
> >  -- totals summary
> >  -- slabs sorted by size
> >  -- slabs sorted by loss (waste)
> > 
> > The patches also introduces several new slabinfo options to limit the
> > number of slabs reported, sort slabs by loss (waste); and some fixes.
> 
> hm, why the "RFC"?  These patches look more mature than most of the
> stuff I get ;)
> 

Thank you, sir.

I wasn't so sure about the gnuplot script, that's why I added RFC.


> You should have cc'ed linux-mm on these patches: nobody will have
> noticed them.

I should have done that, my bad.
`./scripts/get_maintainer.pl -f tools/vm/' confused me.


> slabinfo is documented a bit in Documentation/vm/slub.txt.  Please
> review that file for accuracy and completeness.  It should at least
> draw readers' attention to the new tools/vm/slabinfo-gnuplot.sh.

Will take a look.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
