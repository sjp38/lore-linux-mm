Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 26C878D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 16:38:04 -0500 (EST)
Date: Wed, 9 Feb 2011 13:37:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/4] memcg: operate on page quantities internally
Message-Id: <20110209133757.735b08ab.akpm@linux-foundation.org>
In-Reply-To: <1297249313-23746-1-git-send-email-hannes@cmpxchg.org>
References: <1297249313-23746-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed,  9 Feb 2011 12:01:49 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> Hi,
> 
> this patch set converts the memcg charge and uncharge paths to operate
> on multiples of pages instead of bytes.  It already was a good idea
> before, but with the merge of THP we made a real mess by specifying
> huge pages alternatingly in bytes or in number of regular pages.
> 
> If I did not miss anything, this should leave only res_counter and
> user-visible stuff in bytes.  The ABI probably won't change, so next
> up is converting res_counter to operate on page quantities.
> 

I worry that there will be unconverted code and we'll end up adding
bugs.

A way to minimise the risk is to force compilation errors and warnings:
rename fields and functions, reorder function arguments.  Did your
patches do this as much as they could have?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
