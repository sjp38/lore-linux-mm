Date: Wed, 4 Oct 2006 12:43:56 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Checking page_count(page) in invalidate_complete_page
Message-Id: <20061004124356.97743697.akpm@osdl.org>
In-Reply-To: <45240B94.4070808@oracle.com>
References: <4518333E.2060101@oracle.com>
	<20060928094023.e888d533.akpm@osdl.org>
	<451BFB84.5070903@oracle.com>
	<20060928100306.0b58f3c7.akpm@osdl.org>
	<451C01C8.7020104@oracle.com>
	<451C6AAC.1080203@yahoo.com.au>
	<451D8371.2070101@oracle.com>
	<1159562724.13651.39.camel@lappy>
	<451D89E7.7020307@oracle.com>
	<1159564637.13651.44.camel@lappy>
	<20060929144421.48f9f1bd.akpm@osdl.org>
	<451D94A7.9060905@oracle.com>
	<20060929152951.0b763f6a.akpm@osdl.org>
	<451F425F.8030609@oracle.com>
	<4520FFB6.3040801@RedHat.com>
	<1159795522.6143.7.camel@lade.trondhjem.org>
	<20061002095727.05cd052f.akpm@osdl.org>
	<4521460B.8000504@RedHat.com>
	<20061002112005.d02f84f7.akpm@osdl.o! rg>
	<45216233.5010602@RedHat.com>
	<4521C79A.6090102@oracle.com>
	<1159849117.5420.17.camel@lade.trondhjem.org>
	<4522B112.3030207@oracle.com>
	<1159902601.23752.11.camel@lade.trondhjem.org>
	<20061003143701.93a66b84.akpm@osdl.or!
 g>
	<45240B94.4070808@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: chuck.lever@oracle.com
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <SteveD@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 04 Oct 2006 15:29:24 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> Andrew Morton wrote:
> > On Tue, 03 Oct 2006 15:10:01 -0400
> > Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > 
> >>>>> +	result = invalidate_inode_pages2(mapping);
> >>>>> +	if (unlikely(result) < 0) {
> >>>>> +		nfs_inc_stats(inode, NFSIOS_INVALIDATEFAILED);
> >>>>> +		printk(KERN_ERR
> >>>>> +			"NFS: error %d invalidating pages for inode (%s/%Ld)\n",
> >>>>> +				result, inode->i_sb->s_id,
> >>>>> +				(long long)NFS_FILEID(inode));
> >>>> So what _are_ users expected to do about this? Sue us? Complain bitterly
> >>>> to lkml, and then get told that the VM is broken?
> >>> Such a message will be reported to distributors or lkml, and we will be 
> >>> able to collect data about the scenario where there is a problem.
> >> i.e. we're throwing our hands up into the air, and saying "we don't
> >> understand what is going on here"?
> >>
> >> Sorry, but that is not an option. If we can't design a clearly defined
> >> API for cache invalidation, with well defined errors, then we should all
> >> go home and start learning Solaris programming now.
> > 
> > I don't think we need the stats increment in there.  We could make it a
> > plain WARN_ON() or BUG_ON().  Or just whack a printk in there.  It's hardly
> > a big deal.
> 
> A "WARN_ON(ret != 0);" placed at the end of 
> invalidate_inode_pages2_range() should be sufficient and harmless.

true.  I think. I'll take a look at adding a WARN_ON_ONCE().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
