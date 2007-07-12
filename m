Message-ID: <46959516.30007@yahoo.com.au>
Date: Thu, 12 Jul 2007 12:42:30 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: block_page_mkwrite? (Re: fault vs invalidate race (Re: -mm merge
 plans for 2.6.23))
References: <20070710013152.ef2cd200.akpm@linux-foundation.org> <46957BE1.1010104@yahoo.com.au> <20070712023100.GX12413810@sgi.com>
In-Reply-To: <20070712023100.GX12413810@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, xfs-oss <xfs@oss.sgi.com>
List-ID: <linux-mm.kvack.org>

David Chinner wrote:
> On Thu, Jul 12, 2007 at 10:54:57AM +1000, Nick Piggin wrote:
> 
>>Andrew Morton wrote:
>>
>>>The fault-vs-invalidate race fix.  I have belatedly learned that these 
>>>need
>>>more work, so their state is uncertain.
>>
>>The more work may turn out being too much for you (although it is nothing
>>exactly tricky that would introduce subtle bugs, it is a fair amont of 
>>churn).
> 
> 
> OK, so does that mean we can finally get the block_page_mkwrite
> patches merged?
> 
> i.e.:
> 
> http://marc.info/?l=linux-kernel&m=117426058311032&w=2
> http://marc.info/?l=linux-kernel&m=117426070111136&w=2
> 
> I've got up-to-date versions of them ready to go and they've been
> consistently tested thanks to the XFSQA test I wrote for the bug
> that it fixes. I've been holding them out-of-tree for months now
> because ->fault was supposed to supercede this interface.....

Yeah, as I've said, don't hold them back because of me. They are
relatively simple enough that I don't see why they couldn't be
merged in this window.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
