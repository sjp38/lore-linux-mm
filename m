Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 0AA296B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 07:45:48 -0400 (EDT)
Received: by yenl1 with SMTP id l1so2017249yen.14
        for <linux-mm@kvack.org>; Wed, 15 Aug 2012 04:45:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLEJe=aZHHAu3JT5-U7JsXMenP5xUc=aeKrhz6VcKuPOVQ@mail.gmail.com>
References: <1344974585-9701-1-git-send-email-elezegarcia@gmail.com>
	<0000013926e9f534-137f9d40-77b0-4dbc-90cb-d588c68e9526-000000@email.amazonses.com>
	<CALF0-+XcmmeWr4qjDoKGit7fqyWwpCk_S9v+F18+x9heN9Y1oA@mail.gmail.com>
	<CAOJsxLEJe=aZHHAu3JT5-U7JsXMenP5xUc=aeKrhz6VcKuPOVQ@mail.gmail.com>
Date: Wed, 15 Aug 2012 08:45:47 -0300
Message-ID: <CALF0-+VTY1YH0+wT_HLgpCNNzZAKuce6gDHrRbJhhEBE80FGVQ@mail.gmail.com>
Subject: Re: [PATCH] mm, slob: Drop usage of page->private for storing
 page-sized allocations
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>

Hi Pekka,

On Wed, Aug 15, 2012 at 8:42 AM, Pekka Enberg <penberg@kernel.org> wrote:
> On Wed, Aug 15, 2012 at 2:38 PM, Ezequiel Garcia <elezegarcia@gmail.com> wrote:
>> Who's the slob maintainer? Currently MAINTAINERS file
>> mentions slob's author Matt Mackal, but I didn't notice his presence
>> in this ML.
>
> I'm handling patches for all slab allocators.

Ah, great. I sent these three based on your branch:

git://git.kernel.org/pub/scm/linux/kernel/git/penberg/linux.git slab/next

I hope this is ok.

Regards and thank you,
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
