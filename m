Message-ID: <4354B7A6.6030909@yahoo.com.au>
Date: Tue, 18 Oct 2005 18:51:50 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Page migration via Swap V2: Page Eviction
References: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>	<20051018004937.3191.42181.sendpatchset@schroedinger.engr.sgi.com> <20051017180451.358f9dcc.akpm@osdl.org>
In-Reply-To: <20051017180451.358f9dcc.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, ak@suse.de
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>Christoph Lameter <clameter@sgi.com> wrote:
>
>>+		write_lock_irq(&mapping->tree_lock);
>> +
>> +		if (page_count(page) != 2 || PageDirty(page)) {
>> +			write_unlock_irq(&mapping->tree_lock);
>> +			goto retry_later_locked;
>> +		}
>>
>
>This needs the (uncommented (grr)) smp_rmb() copied-and-pasted as well.
>
>It's a shame about the copy-and-pasting :(   Is it unavoidable?
>
>

It is commented. The comment says that page_count must be tested
before PageDirty. The code simply didn't match the comment before,
so it didn't warrant any more commenting aside from the changelog.

Nick


Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
