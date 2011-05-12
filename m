Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0C75390010B
	for <linux-mm@kvack.org>; Thu, 12 May 2011 18:14:37 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p4CMEYJI003417
	for <linux-mm@kvack.org>; Thu, 12 May 2011 15:14:35 -0700
Received: from pxi6 (pxi6.prod.google.com [10.243.27.6])
	by wpaz9.hot.corp.google.com with ESMTP id p4CMEW71018536
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 May 2011 15:14:33 -0700
Received: by pxi6 with SMTP id 6so1521024pxi.3
        for <linux-mm@kvack.org>; Thu, 12 May 2011 15:14:32 -0700 (PDT)
Date: Thu, 12 May 2011 15:14:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] comm: ext4: Protect task->comm access by using
 %ptc
In-Reply-To: <1305073386-4810-4-git-send-email-john.stultz@linaro.org>
Message-ID: <alpine.DEB.2.00.1105121513070.9130@chino.kir.corp.google.com>
References: <1305073386-4810-1-git-send-email-john.stultz@linaro.org> <1305073386-4810-4-git-send-email-john.stultz@linaro.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, 10 May 2011, John Stultz wrote:

> Converts ext4 comm access to use the safe printk %ptc accessor.
> 
> CC: Ted Ts'o <tytso@mit.edu>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: David Rientjes <rientjes@google.com>
> CC: Dave Hansen <dave@linux.vnet.ibm.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: linux-mm@kvack.org
> Signed-off-by: John Stultz <john.stultz@linaro.org>

I like how this patch illustrates how easy it is to use the new method for 
printing a task's command, but it would probably be easier to get the 
first two patches in the series (those that add the seqlock and then %ptc) 
merged in mainline and then break out a series of conversions such as this 
that could go through the individual maintainer's trees.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
