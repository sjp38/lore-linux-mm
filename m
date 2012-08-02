Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 08D1F6B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 10:10:27 -0400 (EDT)
Date: Thu, 2 Aug 2012 09:10:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [00/16] Sl[auo]b: Common code rework V8
In-Reply-To: <501A3357.9000607@parallels.com>
Message-ID: <alpine.DEB.2.00.1208020907250.23049@router.home>
References: <20120801211130.025389154@linux.com> <501A3357.9000607@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, Glauber Costa wrote:

> That said, unless I am missing something, you seem to have added nothing
> in the middle of the series, all new patches go in the end. Am I right?

Correct.\

> In this case, we could merge patches 1-9 if Pekka is fine with them, and
> then move on.

I'd say take it from the top and merge as much patch as we can get into a
a shapre where we have confidence in the approach being right and the
patches being workable.

The first 2 patches should go directly into the tree since they just
improve debuggability and the second patch actually fixes a memory leak.

The next couple could go into next. Not sure where that would end but we
have a long road to go (and I have lots of patches that have not seen
the daylight yet) and therefore I would suggest to work the next two
weeks on cranking out as much as possible and get what we can into -next.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
