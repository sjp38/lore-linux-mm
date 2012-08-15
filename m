Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 07B256B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 07:38:13 -0400 (EDT)
Received: by yenl1 with SMTP id l1so2009066yen.14
        for <linux-mm@kvack.org>; Wed, 15 Aug 2012 04:38:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013926e9f534-137f9d40-77b0-4dbc-90cb-d588c68e9526-000000@email.amazonses.com>
References: <1344974585-9701-1-git-send-email-elezegarcia@gmail.com>
	<0000013926e9f534-137f9d40-77b0-4dbc-90cb-d588c68e9526-000000@email.amazonses.com>
Date: Wed, 15 Aug 2012 08:38:12 -0300
Message-ID: <CALF0-+XcmmeWr4qjDoKGit7fqyWwpCk_S9v+F18+x9heN9Y1oA@mail.gmail.com>
Subject: Re: [PATCH] mm, slob: Drop usage of page->private for storing
 page-sized allocations
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>

Hi Christoph,

On Tue, Aug 14, 2012 at 5:53 PM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 14 Aug 2012, Ezequiel Garcia wrote:
>
>> This field was being used to store size allocation so it could be
>> retrieved by ksize(). However, it is a bad practice to not mark a page
>> as a slab page and then use fields for special purposes.
>> There is no need to store the allocated size and
>> ksize() can simply return PAGE_SIZE << compound_order(page).
>
> Acked-by: Christoph Lameter <cl@linux.com>
>

Who's the slob maintainer? Currently MAINTAINERS file
mentions slob's author Matt Mackal, but I didn't notice his presence
in this ML.

Thanks,
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
