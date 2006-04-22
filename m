Message-ID: <444A7B44.1060504@yahoo.com.au>
Date: Sun, 23 Apr 2006 04:51:48 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc][patch] radix-tree: direct data
References: <20060422183154.GF30503@wotan.suse.de>
In-Reply-To: <20060422183154.GF30503@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> This saves around 16MB in tags on my 4GB G5 with a couple of kernel source
                             ^^^^
Make that `radix_tree_node'

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
