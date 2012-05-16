Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id B43416B0081
	for <linux-mm@kvack.org>; Wed, 16 May 2012 10:26:22 -0400 (EDT)
Date: Wed, 16 May 2012 09:26:19 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] SL[AUO]B common code 1/9] [slob] define page struct fields
 used in mm_types.h
In-Reply-To: <4FB357C9.8080308@parallels.com>
Message-ID: <alpine.DEB.2.00.1205160925410.25603@router.home>
References: <20120514201544.334122849@linux.com> <20120514201609.418025254@linux.com> <4FB357C9.8080308@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On Wed, 16 May 2012, Glauber Costa wrote:

> It is of course ok to reuse the field, but what about we make it a union
> between "list" and "lru" ?

That is what this patch does. You are commenting on code that was
removed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
