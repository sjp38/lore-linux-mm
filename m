Date: Wed, 26 Feb 2003 11:03:53 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Silly question: How to map a user space page in kernel space?
Message-ID: <900000.1046286232@[10.10.2.4]>
In-Reply-To: <20030226003334.7e85d5b2.akpm@digeo.com>
References: <A46BBDB345A7D5118EC90002A5072C780A7D57E6@orsmsx116.jf.intel.com>
 <9860000.1046238956@[10.10.2.4]> <20030226003334.7e85d5b2.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: inaky.perez-gonzalez@intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> But be aware that pagefaulting inside kmap_atomic is bad - you can get
>> blocked and rescheduled, so touching user pages, etc is dangerous.
> 
> That's true in 2.4.  In 2.5 a copy_foo_user() inside kmap_atomic()
> will just return a short copy while remaining atomic.
> 
> See mm/filemap.c:filemap_copy_from_user()

Cool - I didn't realise you fixed that up so generically - very nice.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
