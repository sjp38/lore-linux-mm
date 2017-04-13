Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 304756B03A6
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 12:34:17 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id y22so53225162ioe.9
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 09:34:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 205si9439083itd.92.2017.04.13.09.34.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 09:34:16 -0700 (PDT)
Date: Thu, 13 Apr 2017 09:34:11 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC] Re: Costless huge virtual memory? /dev/same, /dev/null?
Message-ID: <20170413163411.GH784@bombadil.infradead.org>
References: <20160229162835.GA2816@var.bordeaux.inria.fr>
 <20170413094200.b4lftvumqt4g36hz@var.youpi.perso.aquilenet.fr>
 <20170413162946.jxyzfdggia2gge76@var.youpi.perso.aquilenet.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170413162946.jxyzfdggia2gge76@var.youpi.perso.aquilenet.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Samuel Thibault <samuel.thibault@ens-lyon.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Apr 13, 2017 at 06:29:46PM +0200, Samuel Thibault wrote:
> (Ideally we'd be able to take the MAP_HUGETLB mmap flag into account to
> map a single huge page repeatedly, even lowering the populating cost,
> but AIUI of the current hugepage support it would be far from easy)

You could implement ->map_pages instead of (or as well as) ->fault, which
would lower your costs if that is a concern.  I think the eventual intent
is that map_pages would be able to populate a PMD or even a PUD.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
