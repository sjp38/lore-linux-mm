Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E9C816B0092
	for <linux-mm@kvack.org>; Sat,  9 Jul 2011 16:47:50 -0400 (EDT)
Date: Sat, 9 Jul 2011 13:47:49 -0700
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] mm/readahead: Remove file_ra_state from arguments
 of count_history_pages.
Message-ID: <20110709204749.GB17463@localhost>
References: <cover.1310239575.git.rprabhu@wnohang.net>
 <a224acf18cff069f65e7e7eb10261e7dcfbb094f.1310239575.git.rprabhu@wnohang.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a224acf18cff069f65e7e7eb10261e7dcfbb094f.1310239575.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Raghavendra D Prabhu <rprabhu@wnohang.net>

On Sun, Jul 10, 2011 at 03:41:19AM +0800, Raghavendra D Prabhu wrote:
> count_history_pages doesn't require readahead state to calculate the offset from history.
> 
> Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
