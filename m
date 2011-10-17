Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id A00336B002F
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 18:45:31 -0400 (EDT)
Date: Mon, 17 Oct 2011 18:44:10 -0400 (EDT)
Message-Id: <20111017.184410.578309826256473077.davem@davemloft.net>
Subject: Re: [PATCH 2/3] sparc: gup_pte_range() support THP based tail
 recounting
From: David Miller <davem@davemloft.net>
In-Reply-To: <1318862517-7042-3-git-send-email-aarcange@redhat.com>
References: <1316793432.9084.47.camel@twins>
	<1318862517-7042-1-git-send-email-aarcange@redhat.com>
	<1318862517-7042-3-git-send-email-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com
Cc: peterz@infradead.org, akpm@linux-foundation.org, minchan.kim@gmail.com, walken@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hughd@google.com, jweiner@redhat.com, riel@redhat.com, mgorman@suse.de, kosaki.motohiro@jp.fujitsu.com, shaohua.li@intel.com, paulmck@linux.vnet.ibm.com, benh@kernel.crashing.org

From: Andrea Arcangeli <aarcange@redhat.com>
Date: Mon, 17 Oct 2011 16:41:56 +0200

> Up to this point the code assumed old refcounting for hugepages
> (pre-thp). This updates the code directly to the thp mapcount tail
> page refcounting.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
