Message-ID: <44D82508.9020409@yahoo.com.au>
Date: Tue, 08 Aug 2006 15:45:44 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.18-rc3-mm2: rcu radix tree patches break page migration
References: <Pine.LNX.4.64.0608071556530.23088@schroedinger.engr.sgi.com> <44D7E7DF.1080106@yahoo.com.au> <Pine.LNX.4.64.0608072041010.24071@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608072041010.24071@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: npiggin@suse.de, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:

>On Tue, 8 Aug 2006, Nick Piggin wrote:
>
>
>>Question: can you replace the lookup_slot with a regular lookup, then
>>replace the pointer switch with a radix_tree_delete + radix_tree_insert
>>and see if that works?
>>
>
>Ahh... Okay that makes things work the right way.
>
>Does that mean we need to get rid of radix tree replaces in 
>general?
>

I think it just means that my lookup_slot has a bug somewhere. Also: good
to know that I'm not corrupting anyones pagecache (except yours, and Lee's).

Let me work out what I'm doing wrong. In the meantime if you could send
that patch to akpm as a fixup, that would keep you running. Thanks guys.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
