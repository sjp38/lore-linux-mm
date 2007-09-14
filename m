Subject: Re: [PATCH 3/4] hugetlb: interleave dequeueing of huge pages
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0709141153360.17038@schroedinger.engr.sgi.com>
References: <20070906182134.GA7779@us.ibm.com>
	 <20070906182430.GB7779@us.ibm.com> <20070906182704.GC7779@us.ibm.com>
	 <Pine.LNX.4.64.0709141153360.17038@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 14 Sep 2007 15:03:57 -0400
Message-Id: <1189796638.5315.50.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, wli@holomorphy.com, agl@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-09-14 at 11:54 -0700, Christoph Lameter wrote:
> On Thu, 6 Sep 2007, Nishanth Aravamudan wrote:
> 
> > +static struct page *dequeue_huge_page(void)
> > +{
> > +	static int nid = -1;
> > +	struct page *page = NULL;
> > +	int start_nid;
> > +	int next_nid;
> > +
> > +	if (nid < 0)
> > +		nid = first_node(node_states[N_HIGH_MEMORY]);
> > +	start_nid = nid;
> 
> nid is -1 so the tests are useless.
> 
start_nid is a [private] static variable.  It is initialized to -1 at
boot, and thereafter loops around nodes on each call, as huge pages are
allocated.  It is only == -1 on the very first call to this function. I
think it has worked like this since hugetlbfs was added.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
