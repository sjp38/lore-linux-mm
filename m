Date: Tue, 27 Feb 2001 11:52:03 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: 2.5 page cache improvement idea
Message-ID: <20010227115203.M8409@redhat.com>
References: <Pine.LNX.4.30.0102261829330.5576-100000@today.toronto.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.30.0102261829330.5576-100000@today.toronto.redhat.com>; from bcrl@redhat.com on Mon, Feb 26, 2001 at 06:46:24PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Feb 26, 2001 at 06:46:24PM -0500, Ben LaHaise wrote:
> 
> inode
> 	-> hash table
> 		-> struct page, index, mapping
> 		-> head of b*tree for overflow

Isn't this going to bloat the size of the inode itself horribly,
though?  You don't know in advance how much data you'll be caching
against any given inode, so I can only see this working if you use
dynamic hashing (in which case the btree overflow goes away).

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
