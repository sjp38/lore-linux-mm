Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id A77836B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 09:58:11 -0400 (EDT)
Date: Tue, 22 May 2012 08:58:08 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] slab+slob: dup name string
In-Reply-To: <1337680298-11929-1-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1205220857380.17600@router.home>
References: <1337680298-11929-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>

On Tue, 22 May 2012, Glauber Costa wrote:

> [ v2: Also dup string for early caches, requested by David Rientjes ]

kstrdups that early could cause additional issues. Its better to leave
things as they were.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
