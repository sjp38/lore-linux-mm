Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id A3B9D6B0035
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 03:12:32 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id kp14so4402351pab.5
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 00:12:32 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id t6si6337734pbg.335.2014.01.10.00.12.30
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 00:12:31 -0800 (PST)
Date: Fri, 10 Jan 2014 00:13:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
Message-Id: <20140110001344.2af08f11.akpm@linux-foundation.org>
In-Reply-To: <20140110080504.GA9437@dhcp22.suse.cz>
References: <20140101002935.GA15683@localhost.localdomain>
	<52C5AA61.8060701@intel.com>
	<20140103033303.GB4106@localhost.localdomain>
	<52C6FED2.7070700@intel.com>
	<20140105003501.GC4106@localhost.localdomain>
	<20140106164604.GC27602@dhcp22.suse.cz>
	<20140108101611.GD27937@dhcp22.suse.cz>
	<20140109073259.GK4106@localhost.localdomain>
	<alpine.DEB.2.02.1401091310510.31538@chino.kir.corp.google.com>
	<20140110080504.GA9437@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>

On Fri, 10 Jan 2014 09:05:04 +0100 Michal Hocko <mhocko@suse.cz> wrote:

> > > --- a/mm/huge_memory.c
> > > +++ b/mm/huge_memory.c
> > > @@ -100,6 +100,7 @@ static struct khugepaged_scan khugepaged_scan = {
> > >  	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
> > >  };
> > >  
> > > +extern int user_min_free_kbytes;
> > >  
> > 
> > We don't add extern declarations to .c files.  How many other examples of 
> > this can you find in mm/?
> 
> I have suggested this because general visibility is not needed.

It's best to use a common declaration which is seen by the definition
site and all references, so everyone agrees on the variable's type. 
Otherwise we could have "long foo;" in one file and "extern char foo;"
in another and the compiler won't tell us.  I think the linker could
tell us, but it doesn't, afaik.  Perhaps there's an option...

> But if
> you think that it should then include/linux/mm.h sounds like a proper
> place.

mm/internal.h might suit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
