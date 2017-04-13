Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 398FE6B03AC
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 13:04:59 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u77so6926766wrb.6
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 10:04:59 -0700 (PDT)
Received: from mail3-relais-sop.national.inria.fr (mail3-relais-sop.national.inria.fr. [192.134.164.104])
        by mx.google.com with ESMTPS id u36si29598439wrc.219.2017.04.13.10.04.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 10:04:58 -0700 (PDT)
Date: Thu, 13 Apr 2017 19:04:56 +0200
From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: Re: [RFC] Re: Costless huge virtual memory? /dev/same, /dev/null?
Message-ID: <20170413170456.77abmvqs6b6b3hfx@var.youpi.perso.aquilenet.fr>
References: <20160229162835.GA2816@var.bordeaux.inria.fr>
 <20170413094200.b4lftvumqt4g36hz@var.youpi.perso.aquilenet.fr>
 <20170413162946.jxyzfdggia2gge76@var.youpi.perso.aquilenet.fr>
 <20170413163411.GH784@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170413163411.GH784@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Matthew Wilcox, on jeu. 13 avril 2017 09:34:11 -0700, wrote:
> On Thu, Apr 13, 2017 at 06:29:46PM +0200, Samuel Thibault wrote:
> > (Ideally we'd be able to take the MAP_HUGETLB mmap flag into account to
> > map a single huge page repeatedly, even lowering the populating cost,
> > but AIUI of the current hugepage support it would be far from easy)
> 
> You could implement ->map_pages instead of (or as well as) ->fault, which
> would lower your costs if that is a concern.

Yes it is a concern.  I was a bit afraid that implementing map_pages
would be frowned upon, and getting in first a simple yet already useful
/dev/garbage would work better :)

I'm fine with doing either.

> I think the eventual intent is that map_pages would be able to
> populate a PMD or even a PUD.

Yes.  Allocating such a big page can be a problem, though.

Samuel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
