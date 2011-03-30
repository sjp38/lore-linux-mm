Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CD6818D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 20:06:15 -0400 (EDT)
Date: Wed, 30 Mar 2011 16:36:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] Unmapped page cache control (v5)
Message-Id: <20110330163607.0984b831.akpm@linux-foundation.org>
In-Reply-To: <20110330052819.8212.1359.stgit@localhost6.localdomain6>
References: <20110330052819.8212.1359.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com

On Wed, 30 Mar 2011 11:00:26 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Data from the previous patchsets can be found at
> https://lkml.org/lkml/2010/11/30/79

It would be nice if the data for the current patchset was present in
the current patchset's changelog!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
