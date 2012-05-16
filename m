Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 4CF936B00EA
	for <linux-mm@kvack.org>; Wed, 16 May 2012 10:32:04 -0400 (EDT)
Date: Wed, 16 May 2012 09:32:01 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] SL[AUO]B common code 6/9] slabs: Use a common mutex
 definition
In-Reply-To: <4FB36685.4030104@parallels.com>
Message-ID: <alpine.DEB.2.00.1205160931200.25603@router.home>
References: <20120514201544.334122849@linux.com> <20120514201612.262732939@linux.com> <4FB36685.4030104@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On Wed, 16 May 2012, Glauber Costa wrote:

> Now, won't this hurt performance of the slob allocator, that seems to gain its
> edge from its simplicity ?

Well the cache creation and removal is usually not that performance
critical. Code exists anyway for various other things so we add some
features to SLOB in the process.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
