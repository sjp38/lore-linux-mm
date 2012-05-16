Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 247856B0082
	for <linux-mm@kvack.org>; Wed, 16 May 2012 11:41:53 -0400 (EDT)
Date: Wed, 16 May 2012 10:41:50 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] SL[AUO]B common code 3/9] Extract common fields from struct
 kmem_cache
In-Reply-To: <4FB35E7F.8030303@parallels.com>
Message-ID: <alpine.DEB.2.00.1205161041100.25603@router.home>
References: <20120514201544.334122849@linux.com> <20120514201610.559075441@linux.com> <4FB35E7F.8030303@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On Wed, 16 May 2012, Glauber Costa wrote:

> Who defines struct kmem_cache for the slob now ?

The hunk was dropped that added this to include/linux/slob_def.h. Next
post will include that.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
