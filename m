Received: from fujitsu3.fujitsu.com (localhost [127.0.0.1])
	by fujitsu3.fujitsu.com (8.12.10/8.12.9) with ESMTP id iAHNLhpa008167
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 15:21:43 -0800 (PST)
Date: Wed, 17 Nov 2004 15:21:26 -0800
From: Yasunori Goto <ygoto@us.fujitsu.com>
Subject: Re: [Lhms-devel] [RFC] fix for hot-add enabled SRAT/BIOS and numa KVA areas
In-Reply-To: <1100731354.12373.224.camel@localhost>
References: <20041117133315.92B7.YGOTO@us.fujitsu.com> <1100731354.12373.224.camel@localhost>
Message-Id: <20041117152043.92BB.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: keith <kmannth@us.ibm.com>, external hotplug mem list <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, Chris McDermott <lcm@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> You can't remove nodes, just DIMMs.  The x440 hotplug is more like the
> SMP case that I've always been concerned with.

OK. I understood. 
Thanks.

-- 
Yasunori Goto <ygoto at us.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
