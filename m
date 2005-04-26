From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17006.27177.240316.526941@gargle.gargle.HOWL>
Date: Tue, 26 Apr 2005 20:19:53 +0400
Subject: Re: [PATCH]: VM 7/8 cluster pageout
In-Reply-To: <20050426023635.37ab2c38.akpm@osdl.org>
References: <16994.40699.267629.21475@gargle.gargle.HOWL>
	<20050425211514.29e7c86b.akpm@osdl.org>
	<17006.1794.857289.487941@gargle.gargle.HOWL>
	<20050426023635.37ab2c38.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:
 > Nikita Danilov <nikita@clusterfs.com> wrote:
 > >
 > > Andrew Morton writes:
 > >  > Nikita Danilov <nikita@clusterfs.com> wrote:
 > >  > >
 > >  > > Implement pageout clustering at the VM level.
 > >  > 
 > >  > I dunno...
 > >  > 
 > >  > Once __mpage_writepages() has started I/O against the pivot page, I don't
 > >  > see that we have any guarantees that some other CPU cannot come in,
 > >  > truncated or reclaim all the inode's pages and then reclaimed the inode
 > >  > altogether.  While __mpage_writepages() is still dinking with it all.
 > > 
 > > Ah, silly me. Will __iget(page->mapping->host) in pageout_cluster() be
 > > enough? We risk truncate on matching iput(), but VM scanner calls iput()
 > > on inodes with ->i_nlink == 0 already (from shrink_dcache()).
 > 
 > I have vague memories about iput() in page reclaim causing deadlocks or
 > some other nastiness.  Maybe not.

Aren't you talking about

http://marc.theaimsgroup.com/?t=108272583200001&r=1&w=2

by any chance? As I remember it, conclusion was that file system has to
be ready to handle final iput() from within GFP_FS allocation.

 > 

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
