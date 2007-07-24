Date: Tue, 24 Jul 2007 18:13:48 +0100
Subject: Re: [patch] fix hugetlb page allocation leak
Message-ID: <20070724171348.GA9625@skynet.ie>
References: <b040c32a0707231711p3ea6b213wff15e7a58ee48f61@mail.gmail.com> <20070723172019.376ca936.akpm@linux-foundation.org> <20070723194856.40d35666.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070723194856.40d35666.randy.dunlap@oracle.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (23/07/07 19:48), Randy Dunlap didst pronounce:
> On Mon, 23 Jul 2007 17:20:19 -0700 Andrew Morton wrote:
> 
> > On Mon, 23 Jul 2007 17:11:49 -0700
> > "Ken Chen" <kenchen@google.com> wrote:
> > 
> > > dequeue_huge_page() has a serious memory leak upon hugetlb page
> > > allocation.  The for loop continues on allocating hugetlb pages out of
> > > all allowable zone, where this function is supposedly only dequeue one
> > > and only one pages.
> > > 
> > > Fixed it by breaking out of the for loop once a hugetlb page is found.
> > > 
> > > 
> > > Signed-off-by: Ken Chen <kenchen@google.com>
> 
> Acked-and-tested-by: Randy Dunlap <randy.dunlap@oracle.com>
> 

Confirmed. Before the patch, I'm seeing pages leak where the pool still
has pages after 0 is written to /proc/sys/vm/nr_hugepages . After the
patch, it seems fine.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
