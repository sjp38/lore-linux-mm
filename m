Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id C91FE6B002C
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 19:19:09 -0500 (EST)
Date: Tue, 14 Feb 2012 16:19:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] prio_tree: remove unnecessary code in
 prio_tree_replace
Message-Id: <20120214161908.3fbc2c27.akpm@linux-foundation.org>
In-Reply-To: <4F3A2285.7060700@linux.vnet.ibm.com>
References: <4F3A2285.7060700@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 14 Feb 2012 16:59:49 +0800
Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com> wrote:

> Remove the code since 'node' has already been initialized in the
> begin of the function
> 

The patches look good to me.

You appear to be the first person to touch this code in seven years. 
That must be a world record.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
