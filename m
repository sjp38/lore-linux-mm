Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D53756B002D
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 05:23:43 -0400 (EDT)
Date: Thu, 20 Oct 2011 05:23:33 -0400 (EDT)
Message-Id: <20111020.052333.865812021350188883.davem@davemloft.net>
Subject: Re: [PATCH 0/6] skb fragment API: convert network drivers (part V,
 take 2)
From: David Miller <davem@davemloft.net>
In-Reply-To: <1319101275.3385.129.camel@zakaz.uk.xensource.com>
References: <1319101275.3385.129.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian.Campbell@citrix.com
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Thu, 20 Oct 2011 10:01:15 +0100

> The following series is the second attempt to convert a fifth (and
> hopefully final) batch of network drivers to the SKB pages fragment API
> introduced in 131ea6675c76.

Applied, thanks Ian.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
