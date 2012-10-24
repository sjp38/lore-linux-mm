Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 3D7DF6B0070
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 10:29:10 -0400 (EDT)
Date: Wed, 24 Oct 2012 14:29:09 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 1/2] kmem_cache: include allocators code directly into
 slab_common
In-Reply-To: <1351087158-8524-2-git-send-email-glommer@parallels.com>
Message-ID: <0000013a932d456c-8f0cbbce-e3f7-4f2a-b051-7b093a8cfc7e-000000@email.amazonses.com>
References: <1351087158-8524-1-git-send-email-glommer@parallels.com> <1351087158-8524-2-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: andi@firstfloor.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>

On Wed, 24 Oct 2012, Glauber Costa wrote:

> Because of that, we either have to move all the entry points to the
> mm/slab.h and rely heavily on the pre-processor, or include all .c files
> in here.

Hmm... That is a bit of a radical solution. The global optimizations now
possible with the new gcc compiler include the ability to fold functions
across different linkable objects. Andi, is that usable for kernel builds?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
