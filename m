Subject: Re: [patch 4/8] mm: write_cache_pages type overflow fix
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <20081010155447.GA14628@skywalker>
References: <20081009155039.139856823@suse.de>
	 <20081009174822.516911376@suse.de> <20081009082336.GB6637@infradead.org>
	 <20081010131030.GB16353@mit.edu> <20081010131325.GA16246@infradead.org>
	 <20081010133719.GC16353@mit.edu> <1223646482.25004.13.camel@quoit>
	 <20081010140535.GD16353@mit.edu> <20081010140829.GA7983@infradead.org>
	 <20081010155447.GA14628@skywalker>
Content-Type: text/plain
Date: Fri, 10 Oct 2008 11:59:18 -0400
Message-Id: <1223654358.8209.0.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>, Theodore Tso <tytso@mit.edu>, Steven Whitehouse <steve@chygwyn.com>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-10-10 at 21:24 +0530, Aneesh Kumar K.V wrote:
> On Fri, Oct 10, 2008 at 10:08:29AM -0400, Christoph Hellwig wrote:
> > On Fri, Oct 10, 2008 at 10:05:35AM -0400, Theodore Tso wrote:
> > > 3) A version which (optionally via a flag in the wbc structure)
> > > instructs write_cache_pages() to not pursue those updates.  This has
> > > not been written yet.
> > 
> > This one sounds best to me (although we'd have to actualy see it..)
> 
> something like  the below ?
>
> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> index bd91987..7599af2 100644
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -63,6 +63,8 @@ struct writeback_control {
>  	unsigned for_writepages:1;	/* This is a writepages() call */
>  	unsigned range_cyclic:1;	/* range_start is cyclic */
>  	unsigned more_io:1;		/* more io to be dispatched */
> +	/* flags which control the write_cache_pages behaviour */
> +	int writeback_flags;
>  };

Doesn't seem in line with the bitflag method currently used in struct
writeback_control.

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
