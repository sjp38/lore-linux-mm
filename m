Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 433D99000C6
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 15:05:15 -0400 (EDT)
Message-ID: <4E78E3DF.1070501@redhat.com>
Date: Tue, 20 Sep 2011 15:05:03 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/8] page_referenced: replace vm_flags parameter with
 struct pr_info
References: <1316230753-8693-1-git-send-email-walken@google.com> <1316230753-8693-2-git-send-email-walken@google.com>
In-Reply-To: <1316230753-8693-2-git-send-email-walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>

On 09/16/2011 11:39 PM, Michel Lespinasse wrote:
> Introduce struct pr_info, passed into page_referenced() family of functions,
> to represent information about the pte references that have been found for
> that page. Currently contains the vm_flags information as well as
> a PR_REFERENCED flag. The idea is to make it easy to extend the API
> with new flags.
>
>
> Signed-off-by: Michel Lespinasse<walken@google.com>

I have to agree with Joe's suggested name change.

Other than that, this patch looks good (will ack the next version).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
