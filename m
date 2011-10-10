Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DEE016B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 15:17:06 -0400 (EDT)
Date: Mon, 10 Oct 2011 15:16:58 -0400 (EDT)
Message-Id: <20111010.151658.663093734330216843.davem@davemloft.net>
Subject: Re: [PATCH 0/9] skb fragment API: convert network drivers (part V)
From: David Miller <davem@davemloft.net>
In-Reply-To: <1318272731.2567.4.camel@edumazet-laptop>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
	<20111010.142040.2267571270586671416.davem@davemloft.net>
	<1318272731.2567.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: eric.dumazet@gmail.com
Cc: Ian.Campbell@citrix.com, netdev@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Oct 2011 20:52:11 +0200

> Is it OK if I send a single patch right now ?
> 
> I am asking because it might clash a bit with Ian work.

Feel free to do so, we'll sort it out somehow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
