Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D46786B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 14:20:47 -0400 (EDT)
Date: Mon, 10 Oct 2011 14:20:40 -0400 (EDT)
Message-Id: <20111010.142040.2267571270586671416.davem@davemloft.net>
Subject: Re: [PATCH 0/9] skb fragment API: convert network drivers (part V)
From: David Miller <davem@davemloft.net>
In-Reply-To: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian.Campbell@citrix.com
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Mon, 10 Oct 2011 12:11:16 +0100

> I think "struct subpage" is a generally useful tuple I added to a
> central location (mm_types.h) rather than somewhere networking or driver
> specific but I can trivially move if preferred.

I'm fine with the patch series, but this generic datastructure
addition needs some feedback first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
