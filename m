Date: Thu, 10 Apr 2003 09:46:24 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] bootmem speedup from the IA64 tree
Message-ID: <216910000.1049993184@[10.10.2.4]>
In-Reply-To: <20030410033533.21343911.akpm@digeo.com>
References: <20030410122421.A17889@lst.de> <20030410033533.21343911.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Christoph Hellwig <hch@lst.de>
Cc: davidm@napali.hpl.hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> This patch is from the IA64 tree, with some minor cleanups by me.
>> David described it as:
>> 
>>   This is a performance speed up and some minor indendation fixups.
> 
> OK, thanks - I'll queue this up for a bit of testing.
> 
> Martin, can you please also test this?

Compile-tested against every config I had lying around, and run tested
on my big wierdo-box. Works fine.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
