Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f179.google.com (mail-ea0-f179.google.com [209.85.215.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7CA6B0035
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 03:17:47 -0500 (EST)
Received: by mail-ea0-f179.google.com with SMTP id r15so1916279ead.10
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 00:17:47 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a9si8501199eew.96.2014.01.10.00.17.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 00:17:45 -0800 (PST)
Date: Fri, 10 Jan 2014 09:17:44 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
Message-ID: <20140110081744.GC9437@dhcp22.suse.cz>
References: <52C5AA61.8060701@intel.com>
 <20140103033303.GB4106@localhost.localdomain>
 <52C6FED2.7070700@intel.com>
 <20140105003501.GC4106@localhost.localdomain>
 <20140106164604.GC27602@dhcp22.suse.cz>
 <20140108101611.GD27937@dhcp22.suse.cz>
 <20140109073259.GK4106@localhost.localdomain>
 <alpine.DEB.2.02.1401091310510.31538@chino.kir.corp.google.com>
 <20140110080504.GA9437@dhcp22.suse.cz>
 <20140110001344.2af08f11.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140110001344.2af08f11.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>

On Fri 10-01-14 00:13:44, Andrew Morton wrote:
> On Fri, 10 Jan 2014 09:05:04 +0100 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > > > --- a/mm/huge_memory.c
> > > > +++ b/mm/huge_memory.c
> > > > @@ -100,6 +100,7 @@ static struct khugepaged_scan khugepaged_scan = {
> > > >  	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
> > > >  };
> > > >  
> > > > +extern int user_min_free_kbytes;
> > > >  
> > > 
> > > We don't add extern declarations to .c files.  How many other examples of 
> > > this can you find in mm/?
> > 
> > I have suggested this because general visibility is not needed.
> 
> It's best to use a common declaration which is seen by the definition
> site and all references, so everyone agrees on the variable's type. 
> Otherwise we could have "long foo;" in one file and "extern char foo;"
> in another and the compiler won't tell us.  I think the linker could
> tell us, but it doesn't, afaik.  Perhaps there's an option...
> 
> > But if
> > you think that it should then include/linux/mm.h sounds like a proper
> > place.
> 
> mm/internal.h might suit.

min_free_kbytes is in mm.h so I thought having them together would be
appropriate.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
