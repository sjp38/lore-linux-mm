Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 659F36B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 13:16:21 -0400 (EDT)
Date: Tue, 22 May 2012 12:16:18 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab+slob: dup name string
In-Reply-To: <4FBBAE95.6080608@parallels.com>
Message-ID: <alpine.DEB.2.00.1205221216050.17721@router.home>
References: <1337613539-29108-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205212018230.13522@chino.kir.corp.google.com> <alpine.DEB.2.00.1205220855470.17600@router.home> <4FBBAE95.6080608@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 22 May 2012, Glauber Costa wrote:

> I think that's precisely David's point: that we might want to destroy them
> eventually.

Cannot imagine why.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
