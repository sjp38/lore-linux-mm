Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F15936B005C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 16:16:20 -0400 (EDT)
Date: Thu, 13 Oct 2011 16:16:08 -0400 (EDT)
Message-Id: <20111013.161608.1413756673453885746.davem@davemloft.net>
Subject: Re: [PATCH v7 0/8] Request for inclusion: tcp memory buffers
From: David Miller <davem@davemloft.net>
In-Reply-To: <4E9744A6.5010101@parallels.com>
References: <1318511382-31051-1-git-send-email-glommer@parallels.com>
	<20111013.160031.605700447623532119.davem@davemloft.net>
	<4E9744A6.5010101@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, paul@paulmenage.org, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org

From: Glauber Costa <glommer@parallels.com>
Date: Fri, 14 Oct 2011 00:05:58 +0400

> Thank you for letting me now about your view of this that early.

I depend upon my colleagues to assist me in the large task that is reviewing
the enormous number of networking patches that get submitted.

Unfortunately, none of them got a chance to review this patch set
seriously, since I know most of them (especially Eric Dumazet) would
balk at the overhead you're proposing to add to our stack, just as I
did.

This is the reality of the situation, and I'm sorry to tell you that
snippy retorts when someone does take the time out to review your work
won't help at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
