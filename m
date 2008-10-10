Date: Fri, 10 Oct 2008 10:08:29 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 4/8] mm: write_cache_pages type overflow fix
Message-ID: <20081010140829.GA7983@infradead.org>
References: <20081009155039.139856823@suse.de> <20081009174822.516911376@suse.de> <20081009082336.GB6637@infradead.org> <20081010131030.GB16353@mit.edu> <20081010131325.GA16246@infradead.org> <20081010133719.GC16353@mit.edu> <1223646482.25004.13.camel@quoit> <20081010140535.GD16353@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081010140535.GD16353@mit.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Tso <tytso@mit.edu>
Cc: Steven Whitehouse <steve@chygwyn.com>, Christoph Hellwig <hch@infradead.org>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 10, 2008 at 10:05:35AM -0400, Theodore Tso wrote:
> 3) A version which (optionally via a flag in the wbc structure)
> instructs write_cache_pages() to not pursue those updates.  This has
> not been written yet.

This one sounds best to me (although we'd have to actualy see it..)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
