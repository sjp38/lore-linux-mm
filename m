Message-ID: <4515EF28.9000805@mbligh.org>
Date: Sat, 23 Sep 2006 19:36:24 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
MIME-Version: 1.0
Subject: Re: More thoughts on getting rid of ZONE_DMA
References: <Pine.LNX.4.64.0609212052280.4736@schroedinger.engr.sgi.com> <4514441E.70207@mbligh.org> <Pine.LNX.4.64.0609221321280.9181@schroedinger.engr.sgi.com> <200609230134.45355.ak@suse.de> <Pine.LNX.4.64.0609231907360.16435@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609231907360.16435@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, akpm@google.com, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@steeleye.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sat, 23 Sep 2006, Andi Kleen wrote:
> 
>> The problem is that if someone has a workload with lots of pinned pages
>> (e.g. lots of mlock) then the first 16MB might fill up completely and there 
>> is no chance at all to free it because it's pinned
> 
> Note that mlock'ed pages are movable. mlock only specifies that pages
> must stay in memory. It does not say that they cannot be moved. So
> page migration could help there.
> 
> This brings up a possible problem spot in the current kernel: It seems 
> that the VM is capable of migrating pages from ZONE_DMA to 
> ZONE_NORMAL! So once pages are in memory then they may move out of the 
> DMA-able area.
> 
> I assume the writeback paths have some means of detecting that a
> page is out of range during writeback and then do page bouncing?
> 
> If that is the case then we could simply move movable pages out
> if necessary. That would be a kind of bouncing logic there that
> would only kick in if necessary.

If it's the 16MB DMA window for ia32 we're talking about, wouldn't
it be easier just to remove it from the fallback lists? (assuming
you have at least 128MB of memory or something, blah, blah). Saves
doing migration later.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
