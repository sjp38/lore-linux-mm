Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id EF7596B0008
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 02:36:06 -0500 (EST)
Message-ID: <510F64F9.2050706@parallels.com>
Date: Mon, 4 Feb 2013 11:36:25 +0400
From: Lord Glauber Costa of Sealand <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: stop warning on memcg_propagate_kmem
References: <alpine.LNX.2.00.1302032023280.4611@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1302032023280.4611@eggly.anvils>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/04/2013 08:29 AM, Hugh Dickins wrote:
> Whilst I run the risk of a flogging for disloyalty to the Lord of Sealand,
> I do have CONFIG_MEMCG=y CONFIG_MEMCG_KMEM not set, and grow tired of the
> "mm/memcontrol.c:4972:12: warning: `memcg_propagate_kmem' defined but not
> used [-Wunused-function]" seen in 3.8-rc: move the #ifdef outwards.
> 

Thanks my dear Hugh,

This is no disloyalty at all, and your braveness is indeed much appreciated.

My bad for letting that one slip

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
