Message-ID: <46807B32.6050302@yahoo.com.au>
Date: Tue, 26 Jun 2007 12:34:26 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 1/3] add the fsblock layer
References: <20070624014528.GA17609@wotan.suse.de> <20070624014613.GB17609@wotan.suse.de> <18046.63436.472085.535177@notabene.brown> <467F71C6.6040204@yahoo.com.au> <20070625122906.GB12446@think.oraclecorp.com>
In-Reply-To: <20070625122906.GB12446@think.oraclecorp.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: Neil Brown <neilb@suse.de>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Chris Mason wrote:
> On Mon, Jun 25, 2007 at 05:41:58PM +1000, Nick Piggin wrote:
> 
>>Neil Brown wrote:

>>>Why do you think you need PG_blocks?
>>
>>Block device pagecache (buffer cache) has to be able to accept
>>attachment of either buffers or blocks for filesystem metadata,
>>and call into either buffer.c or fsblock.c based on that.
>>
>>If the page flag is really important, we can do some awful hack
>>like assuming the first long of the private data is flags, and
>>those flags will tell us whether the structure is a buffer_head
>>or fsblock ;) But for now it is just easier to use a page flag.
> 
> 
> The block device pagecache isn't special, and certainly isn't that much
> code.  I would suggest keeping it buffer head specific and making a
> second variant that does only fsblocks.  This is mostly to keep the
> semantics of PagePrivate sane, lets not fuzz the line.

That would require a new inode and address_space for the fsblock
type blockdev pagecache, wouldn't it? I just can't think of a
better non-intrusive way of allowing a buffer_head filesystem and
an fsblock filesystem to live on the same blkdev together.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
