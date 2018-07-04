Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id C79BD6B0005
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 18:54:34 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 39-v6so543940ple.6
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 15:54:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e125-v6si4209831pgc.424.2018.07.04.15.54.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Jul 2018 15:54:33 -0700 (PDT)
Date: Wed, 4 Jul 2018 15:54:31 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: XArray -next inclusion request
Message-ID: <20180704225431.GA16309@bombadil.infradead.org>
References: <20180617021521.GA18455@bombadil.infradead.org>
 <20180617134104.68c24ffc@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180617134104.68c24ffc@canb.auug.org.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, Jun 17, 2018 at 01:41:04PM +1000, Stephen Rothwell wrote:
> Hi Willy,
> 
> On Sat, 16 Jun 2018 19:15:22 -0700 Matthew Wilcox <willy@infradead.org> wrote:
> >
> > Please add
> > 
> > git://git.infradead.org/users/willy/linux-dax.git xarray
> > 
> > to linux-next.  It is based on -rc1.  You will find some conflicts
> > against Dan's current patches to DAX; these are all resolved correctly
> > in the xarray-20180615 branch which is based on next-20180615.
> 
> Added from tomorrow.

Thanks!  I have some additional patches for the IDA that I'd like to
send to Linus as a separate pull request.  Unfortunately, they conflict with
the XArray patches, so I've done them as a separate branch in the same tree:

git://git.infradead.org/users/willy/linux-dax.git ida

Would you prefer to add them as a separate branch to linux-next (to be
pulled after xarray), or would you prefer to replace the xarray pull
with the ida pull?  Either way, you'll get the same commits as the ida
branch is based off the xarray branch.
