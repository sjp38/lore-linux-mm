From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17920.61568.770999.626623@gargle.gargle.HOWL>
Date: Wed, 21 Mar 2007 11:44:48 +0300
Subject: Re: [RFC][PATCH] split file and anonymous page queues #3
In-Reply-To: <46005B4A.6050307@redhat.com>
References: <46005B4A.6050307@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel writes:
 > [ OK, I suck.  I edited yesterday's email with the new info, but forgot
 >    to change the attachment to today's patch.  Here is today's patch. ]
 > 
 > Split the anonymous and file backed pages out onto their own pageout
 > queues.  This we do not unnecessarily churn through lots of anonymous
 > pages when we do not want to swap them out anyway.

Won't this re-introduce problems similar to ones due to split
inactive_clean/inactive_dirty queues we had in the past?

For example, by rotating anon queues faster than file queues, kernel
would end up reclaiming anon pages that are hotter (in "absolute" LRU
order) than some file pages.

Nikita.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
