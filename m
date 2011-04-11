Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 596968D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:29:38 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3BLASYY007096
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:10:28 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 0941F6E8039
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:29:36 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3BLTZYU218688
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:29:35 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3BLTYsd028091
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 15:29:35 -0600
Subject: Re: [PATCH resend^2] mm: increase RECLAIM_DISTANCE to 30
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110411172004.0361.A69D9226@jp.fujitsu.com>
References: <20110411172004.0361.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 11 Apr 2011 14:29:31 -0700
Message-ID: <1302557371.7286.16607.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris McDermott <lcm@linux.vnet.ibm.com>

On Mon, 2011-04-11 at 17:19 +0900, KOSAKI Motohiro wrote:
> This patch raise zone_reclaim_mode threshold to 30. 30 don't have
> specific meaning. but 20 mean one-hop QPI/Hypertransport and such
> relatively cheap 2-4 socket machine are often used for tradiotional
> server as above. The intention is, their machine don't use
> zone_reclaim_mode.

I know specifically of pieces of x86 hardware that set the information
in the BIOS to '21' *specifically* so they'll get the zone_reclaim_mode
behavior which that implies.

They've done performance testing and run very large and scary benchmarks
to make sure that they _want_ this turned on.  What this means for them
is that they'll probably be de-optimized, at least on newer versions of
the kernel.

If you want to do this for particular systems, maybe _that_'s what we
should do.  Have a list of specific configurations that need the
defaults overridden either because they're buggy, or they have an
unusual hardware configuration not really reflected in the distance
table.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
