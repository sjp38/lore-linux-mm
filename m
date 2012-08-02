Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 237B66B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 04:02:14 -0400 (EDT)
Message-ID: <501A3357.9000607@parallels.com>
Date: Thu, 2 Aug 2012 11:59:19 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [00/16] Sl[auo]b: Common code rework V8
References: <20120801211130.025389154@linux.com>
In-Reply-To: <20120801211130.025389154@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On 08/02/2012 01:11 AM, Christoph Lameter wrote:
> 
> V7->V8:
> - Do not use kfree for kmem_cache in slub.
> - Add more patches up to a common
>   scheme for object alignment.

I will review the new patchset anyway. But I believe this is a bad move.
This code is subtle, and all previous pieces that got merged led to
bugs. Which is fine in principle, but indicates that we should move and
review with care. Adding more code to the pool defeats this. I'd say
let's merge what was already reviewed, and then take the next step.

That said, unless I am missing something, you seem to have added nothing
in the middle of the series, all new patches go in the end. Am I right?
In this case, we could merge patches 1-9 if Pekka is fine with them, and
then move on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
