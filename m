Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jB1IK24D029545
	for <linux-mm@kvack.org>; Thu, 1 Dec 2005 13:20:02 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jB1IJSSI096852
	for <linux-mm@kvack.org>; Thu, 1 Dec 2005 11:19:28 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jB1IK1Ag006970
	for <linux-mm@kvack.org>; Thu, 1 Dec 2005 11:20:02 -0700
Subject: Re: Better pagecache statistics ?
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20051201175711.GA17169@dmt.cnet>
References: <1133377029.27824.90.camel@localhost.localdomain>
	 <20051201152029.GA14499@dmt.cnet>
	 <1133452790.27824.117.camel@localhost.localdomain>
	 <1133453411.2853.67.camel@laptopd505.fenrus.org>
	 <20051201170850.GA16235@dmt.cnet>
	 <1133457315.21429.29.camel@localhost.localdomain>
	 <1133457700.2853.78.camel@laptopd505.fenrus.org>
	 <20051201175711.GA17169@dmt.cnet>
Content-Type: text/plain
Date: Thu, 01 Dec 2005 10:20:12 -0800
Message-Id: <1133461212.21429.49.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Arjan van de Ven <arjan@infradead.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-12-01 at 15:57 -0200, Marcelo Tosatti wrote:
> On Thu, Dec 01, 2005 at 06:21:39PM +0100, Arjan van de Ven wrote:
> > On Thu, 2005-12-01 at 09:15 -0800, Badari Pulavarty wrote:
> > > > Most of the issues you mention are null if you move the stats
> > > > maintenance burden to userspace. 
> > > > 
> > > > The performance impact is also minimized since the hooks 
> > > > (read: overhead) can be loaded on-demand as needed.
> > > > 
> > > 
> > > The overhead is - going through each mapping/inode in the system
> > > and dumping out "nrpages" - to get per-file statistics. This is
> > > going to be expensive, need locking and there is no single list 
> > > we can traverse to get it. I am not sure how to do this.
> 
> Can't you add hooks to add_to_page_cache/remove_from_page_cache 
> to record pagecache activity ?

In theory, yes. We already maintain info in "mapping->nrpages".
Trick would be to collect all of them, send them to user space.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
