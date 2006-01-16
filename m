Message-ID: <43CB4EDA.6070803@yahoo.com.au>
Date: Mon, 16 Jan 2006 18:44:26 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Race in new page migration code?
References: <20060114155517.GA30543@wotan.suse.de> <Pine.LNX.4.62.0601140955340.11378@schroedinger.engr.sgi.com> <20060114181949.GA27382@wotan.suse.de> <Pine.LNX.4.62.0601141040400.11601@schroedinger.engr.sgi.com> <43C9DD98.5000506@yahoo.com.au> <Pine.LNX.4.62.0601152251550.17034@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0601152251550.17034@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Magnus Damm <magnus.damm@gmail.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sun, 15 Jan 2006, Nick Piggin wrote:
> 
> 
>>OK (either way is fine), but you should still drop the __isolate_lru_page
>>nonsense and revert it like my patch does.
> 
> 
> Ok with me. Magnus: You needed the __isolate_lru_page for some other 
> purpose. Is that still the case?
> 

Either way, we can remove it from the tree for now.

But I'm almost sure such a user would be wrong too. The reason it is
required is very specific and it is because taking lru_lock and then
looking up a page on the LRU uniquely does not pin the page. If you
find the page via any other means other than simply looking on the
LRU, then get_page_testone is wrong and you should either pin it or
take a normal reference to it instead.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
