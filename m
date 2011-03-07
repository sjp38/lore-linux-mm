Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 494F88D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 11:36:02 -0500 (EST)
Date: Mon, 7 Mar 2011 08:35:13 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 8/8] Add VM counters for transparent hugepages
Message-ID: <20110307163513.GC13384@alboin.amr.corp.intel.com>
References: <1299182391-6061-1-git-send-email-andi@firstfloor.org>
 <1299182391-6061-9-git-send-email-andi@firstfloor.org>
 <20110307172609.8A01.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110307172609.8A01.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> Don't we need to make per zone stastics? I'm afraid small dma zone 
> makes much thp-splitting and screw up this stastics.

Does it? I haven't seen that so far.

If it happens a lot it would be better to disable THP for the 16MB DMA
zone at least. Or did you mean the 4GB zone?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
