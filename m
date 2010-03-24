Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D21D66B020B
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 17:54:31 -0400 (EDT)
Date: Wed, 24 Mar 2010 15:54:23 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 07/11] Memory compaction core
Message-ID: <20100324155423.68c3d5b6@bike.lwn.net>
In-Reply-To: <20100324214742.GL10659@random.random>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
	<1269347146-7461-8-git-send-email-mel@csn.ul.ie>
	<20100324133347.9b4b2789.akpm@linux-foundation.org>
	<20100324145946.372f3f31@bike.lwn.net>
	<20100324211924.GH10659@random.random>
	<20100324152854.48f72171@bike.lwn.net>
	<20100324214742.GL10659@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Mar 2010 22:47:42 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> I think you mistaken a VM_BUG_ON for a:
> 
>   if (could_be_null->something) {
>      WARN_ON(1);
>      return -ESOMETHING;
>   }
> 
> adding a VM_BUG_ON(inode->something) would _still_ be as exploitable
> as the null pointer deference, because it's a DoS. It's not really a
> big deal of an exploit but it _sure_ need fixing.

Ah, but that's the point: these NULL pointer dereferences were not DoS
vulnerabilities - they were full privilege-escalation affairs.  Since
then, some problems have been fixed and some distributors have started
shipping smarter configurations.  But, on quite a few systems a NULL
dereference still has the potential to be fully exploitable; if there's
a possibility of it happening I think we should test for it.  A DoS is
a much better outcome...

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
