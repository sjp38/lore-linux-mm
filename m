Date: Mon, 06 May 2002 19:05:32 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: RE: [RFC][PATCH] dcache and rmap
Message-ID: <258210000.1020737132@flay>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E50CEFA@black.eng.netapp.com>
References: <6440EA1A6AA1D5118C6900902745938E50CEFA@black.eng.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Lever, Charles" <Charles.Lever@netapp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> another good reason to keep these caches small is that
> their data structures are faster to traverse.  when
> they are larger than necessary they probably evict more
> important data from the L1 cache during a dcache or
> inode lookup.

I think a better way to fix this would be by not dumping
everything into one massive global hash table. 

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
