Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 16B749000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 05:00:46 -0400 (EDT)
Date: Wed, 6 Jul 2011 02:01:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/5] mm,debug: VM framework to capture memory reference
 pattern
Message-Id: <20110706020103.53ed8706.akpm@linux-foundation.org>
In-Reply-To: <1309854159-8277-1-git-send-email-ankita@in.ibm.com>
References: <1309854159-8277-1-git-send-email-ankita@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ankita Garg <ankita@in.ibm.com>
Cc: linux-mm@kvack.org, svaidy@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>

On Tue,  5 Jul 2011 13:52:34 +0530 Ankita Garg <ankita@in.ibm.com> wrote:

> 
> This patch series is an instrumentation/debug infrastructure that captures
> the memory reference pattern of applications (workloads). 

Can't the interfaces described in Documentation/vm/pagemap.txt be used
for this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
