Message-ID: <415ACB29.5000104@ammasso.com>
Date: Wed, 29 Sep 2004 09:48:09 -0500
From: Timur Tabi <timur.tabi@ammasso.com>
MIME-Version: 1.0
Subject: Re: get_user_pages() still broken in 2.6
References: <4159E85A.6080806@ammasso.com> <20040929000325.A6758@infradead.org>
In-Reply-To: <20040929000325.A6758@infradead.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:

> get_user_pages locks the page in memory.  It doesn't do anything about ptes.

I don't understand the difference.  I thought a locked page is one that 
stays in memory (i.e. isn't swapped out) and whose physical address 
never changes.  Is that wrong?  All I need to do is keep a page in 
memory at the same physical address until I'm done with it.

-- 
Timur Tabi
Staff Software Engineer
timur.tabi@ammasso.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
