Date: Fri, 10 Oct 2008 09:13:25 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 4/8] mm: write_cache_pages type overflow fix
Message-ID: <20081010131325.GA16246@infradead.org>
References: <20081009155039.139856823@suse.de> <20081009174822.516911376@suse.de> <20081009082336.GB6637@infradead.org> <20081010131030.GB16353@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081010131030.GB16353@mit.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Tso <tytso@mit.edu>
Cc: Christoph Hellwig <hch@infradead.org>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 10, 2008 at 09:10:30AM -0400, Theodore Tso wrote:
> > Aneesh has a patch to kill the range_cont flag, which is queued up for
> > 2.6.28.
> 
> Which tree is this queued up in?  It's not in ext4 or the mm tree...

Oh, it' not queued up yet?  It's part of the patch that switches ext4
to it's own copy of write_cache_pages to fix the buffer write issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
