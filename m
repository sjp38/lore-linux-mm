Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C52846B0047
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 19:16:45 -0500 (EST)
Message-ID: <4B7F29CD.1050703@redhat.com>
Date: Fri, 19 Feb 2010 19:16:13 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/12] mm: Share the anon_vma ref counts between KSM	and
 page migration
References: <1266516162-14154-1-git-send-email-mel@csn.ul.ie> <1266516162-14154-4-git-send-email-mel@csn.ul.ie> <4B7F05BA.4080903@redhat.com> <20100219215826.GF1445@csn.ul.ie>
In-Reply-To: <20100219215826.GF1445@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/19/2010 04:58 PM, Mel Gorman wrote:

> external_refcount is about as good as I can think of to explain what's
> going on :/

Sounds "good" to me.  Much better than giving the wrong
impression that this is the only refcount for the anon_vma.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
