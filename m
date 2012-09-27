Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id F24F46B005D
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 13:53:58 -0400 (EDT)
Date: Thu, 27 Sep 2012 17:53:57 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 4/4] sl[au]b: process slabinfo_show in common code
In-Reply-To: <506480FB.40802@parallels.com>
Message-ID: <0000013a08dd105c-06e1ed72-defd-4e0e-aee6-89f6244328f0-000000@email.amazonses.com>
References: <1348756660-16929-1-git-send-email-glommer@parallels.com> <1348756660-16929-5-git-send-email-glommer@parallels.com> <0000013a08443b02-5715bfe6-9c47-49c5-a951-8a48cc432e42-000000@email.amazonses.com> <506480FB.40802@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 27 Sep 2012, Glauber Costa wrote:

> Yes. As a matter of fact, I first implemented it this way, and later
> switched. I was anticipating that people would be likely to point out
> that those properties are directly derivable from the caches, and it
> would be better to just get them from there.

That is not the case if the information is packet as in the case of SLUB.

SLOB (which at some point also could be supported) has an altogether
different way of arranging objects in pagbes.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
