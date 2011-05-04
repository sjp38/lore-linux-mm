Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3283F6B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 19:43:02 -0400 (EDT)
Date: Wed, 4 May 2011 16:42:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] comm: ext4: Protect task->comm access by using
 get_task_comm()
Message-Id: <20110504164257.5bb61879.akpm@linux-foundation.org>
In-Reply-To: <20110504163657.52dca3fc.akpm@linux-foundation.org>
References: <1303963411-2064-1-git-send-email-john.stultz@linaro.org>
	<1303963411-2064-4-git-send-email-john.stultz@linaro.org>
	<alpine.DEB.2.00.1104281426210.21665@chino.kir.corp.google.com>
	<20110504163657.52dca3fc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org


Also.  As direct access to current->comm is now verboten, we should add
a checkpatch rule to shout at people when they do it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
