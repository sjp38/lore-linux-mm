Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 408136B009B
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 11:44:12 -0500 (EST)
Message-ID: <4B7EBFB8.40904@redhat.com>
Date: Fri, 19 Feb 2010 11:43:36 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/12] mm,migration: Take a reference to the anon_vma
 before migrating
References: <1266516162-14154-1-git-send-email-mel@csn.ul.ie> <1266516162-14154-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1266516162-14154-2-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/18/2010 01:02 PM, Mel Gorman wrote:
> rmap_walk_anon() does not use page_lock_anon_vma() for looking up and
> locking an anon_vma and it does not appear to have sufficient locking to
> ensure the anon_vma does not disappear from under it.
>
> This patch copies an approach used by KSM to take a reference on the
> anon_vma while pages are being migrated. This should prevent rmap_walk()
> running into nasty surprises later because anon_vma has been freed.
>
> Signed-off-by: Mel Gorman<mel@csn.ul.ie>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
