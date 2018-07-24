Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5E8476B0006
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 16:32:48 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id e93-v6so3686136plb.5
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 13:32:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c18-v6sor3451727pgd.80.2018.07.24.13.32.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 13:32:47 -0700 (PDT)
Date: Tue, 24 Jul 2018 13:32:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: thp: remove use_zero_page sysfs knob
In-Reply-To: <20180724090800.g43mmfnuuqwczzb2@kshutemo-mobl1>
Message-ID: <alpine.DEB.2.21.1807241331540.185034@chino.kir.corp.google.com>
References: <1532110430-115278-1-git-send-email-yang.shi@linux.alibaba.com> <20180720123243.6dfc95ba061cd06e05c0262e@linux-foundation.org> <alpine.DEB.2.21.1807201300290.224013@chino.kir.corp.google.com> <3238b5d2-fd89-a6be-0382-027a24a4d3ad@linux.alibaba.com>
 <alpine.DEB.2.21.1807201401390.231119@chino.kir.corp.google.com> <20180722035156.GA12125@bombadil.infradead.org> <alpine.DEB.2.21.1807231323460.105582@chino.kir.corp.google.com> <alpine.DEB.2.21.1807231427550.103523@chino.kir.corp.google.com>
 <20180724090800.g43mmfnuuqwczzb2@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Matthew Wilcox <willy@infradead.org>, Yang Shi <yang.shi@linux.alibaba.com>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 24 Jul 2018, Kirill A. Shutemov wrote:

> > use_zero_page is currently a simple thp flag, meaning it rejects writes 
> > where val != !!val, so perhaps it would be best to overload it with 
> > additional options?  I can imagine 0x2 defining persistent allocation so 
> > that the hzp is not freed when the refcount goes to 0 and 0x4 defining if 
> > the hzp should be per node.  Implementing persistent allocation fixes our 
> > concern with it, so I'd like to start there.  Comments?
> 
> Why not a separate files?
> 

That works as well.  I'll write a patch for persistent allocation first to 
address our most immediate need.
