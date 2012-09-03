Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 89EE06B0062
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 10:44:32 -0400 (EDT)
Message-ID: <5044C190.7010208@parallels.com>
Date: Mon, 3 Sep 2012 18:41:20 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C13 [05/14] Extract a common function for kmem_cache_destroy
References: <20120824160903.168122683@linux.com> <000001395965f8f6-7ff20b9e-f748-4af4-a3c9-a9684022361f-000000@email.amazonses.com>
In-Reply-To: <000001395965f8f6-7ff20b9e-f748-4af4-a3c9-a9684022361f-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 08/24/2012 08:10 PM, Christoph Lameter wrote:
> kmem_cache_destroy does basically the same in all allocators.
> 
> Extract common code which is easy since we already have common mutex handling.
> 
> V1-V2:
> 	- Move percpu freeing to later so that we fail cleaner if
> 		objects are left in the cache [JoonSoo Kim]
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

This code is subtle and could benefit from other reviewers. From my
side, I reviewed it, tested it, and couldn't find any obvious problems.

Reviewed-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
