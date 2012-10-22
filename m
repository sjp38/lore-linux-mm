Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 1BD1B6B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 04:11:08 -0400 (EDT)
Message-ID: <5084FF95.2000401@parallels.com>
Date: Mon, 22 Oct 2012 12:11:01 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: CK2 [06/15] Move kmalloc related function defs
References: <20121019142254.724806786@linux.com> <0000013a79823806-6205c310-dfdc-40fa-ae3f-d7d1a9bc5e80-000000@email.amazonses.com>
In-Reply-To: <0000013a79823806-6205c310-dfdc-40fa-ae3f-d7d1a9bc5e80-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On 10/19/2012 06:51 PM, Christoph Lameter wrote:
> 
> Move these functions higher up in slab.h so that they are grouped with other
> generic kmalloc related definitions.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
Trivial

Acked-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
