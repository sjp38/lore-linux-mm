Date: Wed, 25 Aug 2004 14:19:02 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [Bug 3268] New: Lowmemory exhaustion problem with v2.6.8.1-mm4 16gb
Message-ID: <169840000.1093468741@[10.10.2.4]>
In-Reply-To: <20040825135308.2dae6a5d.akpm@osdl.org>
References: <1093460701.5677.1881.camel@knk><Pine.LNX.4.44.0408252104540.2664-100000@localhost.localdomain> <20040825135308.2dae6a5d.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>
Cc: kmannth@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Hugh Dickins <hugh@veritas.com> wrote:
>> 
>> (hmm, does lowmem shortage exert
>>  any pressure on highmem cache these days, I wonder?);
> 
> It does, indirectly - when we reclaim an unused inode we also shoot down
> all that inode's pagecache.

ISTR that causes some fairly major problems under mem pressure - when we
go to shrink inode cache, it used to sit there for *ages* trying to free
pagecache, particularly if there were a lot of large dirty files. That
was a few months back ... but would anything have fixed that case since then?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
