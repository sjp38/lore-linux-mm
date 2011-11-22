Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C61696B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 02:06:05 -0500 (EST)
Date: Tue, 22 Nov 2011 08:05:13 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: fix the document of pgpgin/pgpgout
Message-ID: <20111122070513.GA3204@cmpxchg.org>
References: <1321922925-14930-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1321922925-14930-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wanlong Gao <gaowanlong@cn.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Mon, Nov 21, 2011 at 04:48:45PM -0800, Ying Han wrote:
> The two memcg stats pgpgin/pgpgout have different meaning than the ones in
> vmstat, which indicates that we picked a bad naming for them. It might be late
> to change the stat name, but better documentation is always helpful.
> 
> Signed-off-by: Ying Han <yinghan@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
