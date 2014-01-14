Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f178.google.com (mail-gg0-f178.google.com [209.85.161.178])
	by kanga.kvack.org (Postfix) with ESMTP id 30B1D6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 15:07:28 -0500 (EST)
Received: by mail-gg0-f178.google.com with SMTP id q2so240816ggc.23
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 12:07:27 -0800 (PST)
Received: from e8.ny.us.ibm.com (e8.ny.us.ibm.com. [32.97.182.138])
        by mx.google.com with ESMTPS id t8si1995783qeu.18.2014.01.14.12.07.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 12:07:27 -0800 (PST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <hanpt@linux.vnet.ibm.com>;
	Tue, 14 Jan 2014 15:07:26 -0500
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 707CEC9004A
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 15:07:22 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0EK7OVD8257874
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 20:07:24 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0EK7Ncw006306
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 15:07:24 -0500
Date: Wed, 15 Jan 2014 04:07:20 +0800
From: Han Pingtian <hanpt@linux.vnet.ibm.com>
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
Message-ID: <20140114200720.GM4106@localhost.localdomain>
References: <52C5AA61.8060701@intel.com>
 <20140103033303.GB4106@localhost.localdomain>
 <52C6FED2.7070700@intel.com>
 <20140105003501.GC4106@localhost.localdomain>
 <20140106164604.GC27602@dhcp22.suse.cz>
 <20140108101611.GD27937@dhcp22.suse.cz>
 <20140110081744.GC9437@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140110081744.GC9437@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>

On Fri, Jan 10, 2014 at 09:17:44AM +0100, Michal Hocko wrote:
> On Fri 10-01-14 00:13:44, Andrew Morton wrote:
> > On Fri, 10 Jan 2014 09:05:04 +0100 Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > > > --- a/mm/huge_memory.c
> > > > > +++ b/mm/huge_memory.c
> > > > > @@ -100,6 +100,7 @@ static struct khugepaged_scan khugepaged_scan = {
> > > > >  	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
> > > > >  };
> > > > >  
> > > > > +extern int user_min_free_kbytes;
> > > > >  
> > > > 
> > > > We don't add extern declarations to .c files.  How many other examples of 
> > > > this can you find in mm/?
> > > 
> > > I have suggested this because general visibility is not needed.
> > 
> > It's best to use a common declaration which is seen by the definition
> > site and all references, so everyone agrees on the variable's type. 
> > Otherwise we could have "long foo;" in one file and "extern char foo;"
> > in another and the compiler won't tell us.  I think the linker could
> > tell us, but it doesn't, afaik.  Perhaps there's an option...
> > 
> > > But if
> > > you think that it should then include/linux/mm.h sounds like a proper
> > > place.
> > 
> > mm/internal.h might suit.
> 
> min_free_kbytes is in mm.h so I thought having them together would be
> appropriate.
> 

This is the latest version which put user_min_free_kbytes in
mm/internal.h. Please have a look. Thanks.
