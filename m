Subject: Re: [PATCH]: VM 5/8 async-writepage
From: Nick Piggin <nickpiggin@yahoo.com.au>
In-Reply-To: <16994.40662.865338.484778@gargle.gargle.HOWL>
References: <16994.40662.865338.484778@gargle.gargle.HOWL>
Content-Type: text/plain
Date: Mon, 18 Apr 2005 11:10:22 +1000
Message-Id: <1113786622.5124.4.camel@npiggin-nld.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2005-04-17 at 21:37 +0400, Nikita Danilov wrote:
> Perform some calls to the ->writepage() asynchronously.
> 

Adds quite a lot of complexity. Does it help any real workload,
I wonder? Would it be possible that this (and the later pageout
cluster) could be handled by pdflush?

-- 
SUSE Labs, Novell Inc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
