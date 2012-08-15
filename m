Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id A17326B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 07:42:11 -0400 (EDT)
Received: by wibhm6 with SMTP id hm6so4495358wib.8
        for <linux-mm@kvack.org>; Wed, 15 Aug 2012 04:42:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALF0-+XcmmeWr4qjDoKGit7fqyWwpCk_S9v+F18+x9heN9Y1oA@mail.gmail.com>
References: <1344974585-9701-1-git-send-email-elezegarcia@gmail.com>
	<0000013926e9f534-137f9d40-77b0-4dbc-90cb-d588c68e9526-000000@email.amazonses.com>
	<CALF0-+XcmmeWr4qjDoKGit7fqyWwpCk_S9v+F18+x9heN9Y1oA@mail.gmail.com>
Date: Wed, 15 Aug 2012 14:42:09 +0300
Message-ID: <CAOJsxLEJe=aZHHAu3JT5-U7JsXMenP5xUc=aeKrhz6VcKuPOVQ@mail.gmail.com>
Subject: Re: [PATCH] mm, slob: Drop usage of page->private for storing
 page-sized allocations
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>

On Wed, Aug 15, 2012 at 2:38 PM, Ezequiel Garcia <elezegarcia@gmail.com> wrote:
> Who's the slob maintainer? Currently MAINTAINERS file
> mentions slob's author Matt Mackal, but I didn't notice his presence
> in this ML.

I'm handling patches for all slab allocators.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
