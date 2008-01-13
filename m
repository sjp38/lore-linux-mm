Date: Sat, 12 Jan 2008 23:46:52 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 1/2] massive code cleanup of sys_msync()
Message-ID: <20080112234652.114bd8cd@bree.surriel.com>
In-Reply-To: <12001992013606-git-send-email-salikhmetov@gmail.com>
References: <12001991991217-git-send-email-salikhmetov@gmail.com>
	<12001992013606-git-send-email-salikhmetov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Salikhmetov <salikhmetov@gmail.com>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com
List-ID: <linux-mm.kvack.org>

On Sun, 13 Jan 2008 07:39:58 +0300
Anton Salikhmetov <salikhmetov@gmail.com> wrote:

> Substantial code cleanup of the sys_msync() function:
> 
> 1) using the PAGE_ALIGN() macro instead of "manual" alignment;
> 2) improved readability of the loop traversing the process memory regions.
> 
> Signed-off-by: Anton Salikhmetov <salikhmetov@gmail.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
