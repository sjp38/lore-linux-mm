Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 186906B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 03:43:04 -0400 (EDT)
Date: Fri, 10 Jun 2011 00:43:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
 instead of failing
Message-Id: <20110610004331.13672278.akpm@linux-foundation.org>
In-Reply-To: <4DF1C9DE.4070605@jp.fujitsu.com>
References: <1306922672-9012-1-git-send-email-dbaryshkov@gmail.com>
	<BANLkTinBkdVd90g3-uiQP41z1S1sXUdRmQ@mail.gmail.com>
	<BANLkTikrRRzGLbMD47_xJz+xpgftCm1C2A@mail.gmail.com>
	<alpine.DEB.2.00.1106011017260.13089@chino.kir.corp.google.com>
	<20110601181918.GO3660@n2100.arm.linux.org.uk>
	<alpine.LFD.2.02.1106012043080.3078@ionos>
	<alpine.DEB.2.00.1106011205410.17065@chino.kir.corp.google.com>
	<alpine.LFD.2.02.1106012134120.3078@ionos>
	<4DF1C9DE.4070605@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: tglx@linutronix.de, rientjes@google.com, linux@arm.linux.org.uk, dbaryshkov@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, pavel@ucw.cz

On Fri, 10 Jun 2011 16:38:06 +0900 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Subject: [PATCH] Revert "mm: fail GFP_DMA allocations when ZONE_DMA is not configured"

Confused.  We reverted this over a week ago.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
