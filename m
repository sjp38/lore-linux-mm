Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id B2DC26B0142
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 03:14:38 -0400 (EDT)
Date: Tue, 26 Jun 2012 09:14:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/5] mm/sparse: fix possible memory leak
Message-ID: <20120626071436.GB6713@tiehlicka.suse.cz>
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1340466776-4976-3-git-send-email-shangw@linux.vnet.ibm.com>
 <20120625154851.GD19810@tiehlicka.suse.cz>
 <20120626061147.GB9483@shangw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120626061147.GB9483@shangw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On Tue 26-06-12 14:11:47, Gavin Shan wrote:
> >> With CONFIG_SPARSEMEM_EXTREME, the root memory section descriptors
> >> are allocated by slab or bootmem allocator. Also, the descriptors
> >> might have been allocated and initialized by others. However, the
> >> memory chunk allocated in current implementation wouldn't be put
> >> into the available pool if others have allocated memory chunk for
> >> that.
> >
> >Who is others? I assume that we can race in hotplug because other than
> >that this is an early initialization code. How can others race?
> >
> 
> I'm sorry that I don't have the real bug against the issue. 

I am not saying the bug is not real. It is just that the changelog
doesn's say how the bug is hit, who is affected and when it has been
introduced. These is essential for stable.


-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
