Subject: Re: [patch 4/8] mm: write_cache_pages type overflow fix
From: Steven Whitehouse <steve@chygwyn.com>
In-Reply-To: <20081010133719.GC16353@mit.edu>
References: <20081009155039.139856823@suse.de>
	 <20081009174822.516911376@suse.de> <20081009082336.GB6637@infradead.org>
	 <20081010131030.GB16353@mit.edu> <20081010131325.GA16246@infradead.org>
	 <20081010133719.GC16353@mit.edu>
Content-Type: text/plain
Date: Fri, 10 Oct 2008 14:48:02 +0100
Message-Id: <1223646482.25004.13.camel@quoit>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Tso <tytso@mit.edu>
Cc: Christoph Hellwig <hch@infradead.org>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 2008-10-10 at 09:37 -0400, Theodore Tso wrote:
> On Fri, Oct 10, 2008 at 09:13:25AM -0400, Christoph Hellwig wrote:
> > On Fri, Oct 10, 2008 at 09:10:30AM -0400, Theodore Tso wrote:
> > > > Aneesh has a patch to kill the range_cont flag, which is queued up for
> > > > 2.6.28.
> > > 
> > > Which tree is this queued up in?  It's not in ext4 or the mm tree...
> > 
> > Oh, it' not queued up yet?  It's part of the patch that switches ext4
> > to it's own copy of write_cache_pages to fix the buffer write issues.
> > 
> 
> I held off queing it up since the version Aneesh did created ext4's
> own copy of write_cache_pages, and given that Nick has a bunch of
> fixes and improvements for write_cache_pages, it confirmed my fears
> that queueing a patch which copied ~100 lines of code into ext4 was
> probably not the best way to go.
> 
I've not looked at ext4's copy of write_cache_pages, but there is also a
copy in GFS2. Its used only for journaled data, and it is pretty much a
direct copy of write_cache_pages except that its split into two so that
a transaction can be opened in the "middle".

Perhaps it would be possible to make some changes so that we can both
share the "core" version of write_cache_pages. My plan was to wait until
Nick's patches have made it to Linus, and then to look into what might
be done,

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
