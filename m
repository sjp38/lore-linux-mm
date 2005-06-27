Date: Mon, 27 Jun 2005 07:08:26 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: [rfc] lockless pagecache
Message-ID: <95150000.1119881306@[10.10.2.4]>
In-Reply-To: <20050627004624.53f0415e.akpm@osdl.org>
References: <42BF9CD1.2030102@yahoo.com.au> <20050627004624.53f0415e.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--Andrew Morton <akpm@osdl.org> wrote (on Monday, June 27, 2005 00:46:24 -0700):

> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>> 
>> First I'll put up some numbers to get you interested - of a 64-way Altix
>>  with 64 processes each read-faulting in their own 512MB part of a 32GB
>>  file that is preloaded in pagecache (with the proper NUMA memory
>>  allocation).
> 
> I bet you can get a 5x to 10x reduction in ->tree_lock traffic by doing
> 16-page faultahead.

Maybe true, but when we last tried that, faultahead sucked for performance
in a more general sense. All the extra setup and teardown cost for 
unnecessary PTEs kills you, even if it's only 4 pages or so.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
