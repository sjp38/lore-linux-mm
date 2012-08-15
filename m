Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 166E36B006C
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 11:45:09 -0400 (EDT)
Date: Wed, 15 Aug 2012 15:45:07 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: try to get cpu partial slab even if we get enough
 objects for cpu freelist
In-Reply-To: <1345045084-7292-1-git-send-email-js1304@gmail.com>
Message-ID: <000001392af5ab4e-41dbbbe4-5808-484b-900a-6f4eba102376-000000@email.amazonses.com>
References: <1345045084-7292-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Thu, 16 Aug 2012, Joonsoo Kim wrote:

> s->cpu_partial determine the maximum number of objects kept
> in the per cpu partial lists of a processor. Currently, it is used for
> not only per cpu partial list but also cpu freelist. Therefore
> get_partial_node() doesn't work properly according to our first intention.

The "cpu freelist" in slub is the number of free objects in a specific
page. There is nothing that s->cpu_partial can do about that.

Maybe I do not understand you correctly. Could you explain this in some
more detail?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
