Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0B9DC6B000E
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 08:33:59 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id a12-v6so886623eda.8
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 05:33:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 61-v6si1025916edc.141.2018.10.23.05.33.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 05:33:57 -0700 (PDT)
Date: Tue, 23 Oct 2018 14:33:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [kvm PATCH 1/2] mm: export __vmalloc_node_range()
Message-ID: <20181023123355.GI32333@dhcp22.suse.cz>
References: <20181020211200.255171-1-marcorr@google.com>
 <20181020211200.255171-2-marcorr@google.com>
 <20181022200617.GD14374@char.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181022200617.GD14374@char.us.oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Marc Orr <marcorr@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com

On Mon 22-10-18 16:06:17, Konrad Rzeszutek Wilk wrote:
> On Sat, Oct 20, 2018 at 02:11:59PM -0700, Marc Orr wrote:
> > The __vmalloc_node_range() is in the include/linux/vmalloc.h file, but
> > it's not exported so it can't be used. This patch exports the API. The
> > motivation to export it is so that we can do aligned vmalloc's of KVM
> > vcpus.
> 
> Would it make more sense to change it to not have __ in front of it?
> Also you forgot to CC the linux-mm folks. Doing that for you.

Please also add a user so that we can see how the symbol is actually
used with a short explanation why the existing API is not suitable.

> > 
> > Signed-off-by: Marc Orr <marcorr@google.com>
> > ---
> >  mm/vmalloc.c | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index a728fc492557..9e7974ab1da4 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -1763,6 +1763,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
> >  			  "vmalloc: allocation failure: %lu bytes", real_size);
> >  	return NULL;
> >  }
> > +EXPORT_SYMBOL_GPL(__vmalloc_node_range);
> >  
> >  /**
> >   *	__vmalloc_node  -  allocate virtually contiguous memory
> > -- 
> > 2.19.1.568.g152ad8e336-goog
> > 

-- 
Michal Hocko
SUSE Labs
