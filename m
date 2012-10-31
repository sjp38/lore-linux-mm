Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 9AEDD6B0068
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 02:56:16 -0400 (EDT)
Received: by mail-ea0-f169.google.com with SMTP id k11so529727eaa.14
        for <linux-mm@kvack.org>; Tue, 30 Oct 2012 23:56:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5085370F.80204@parallels.com>
References: <1350907471-2236-1-git-send-email-elezegarcia@gmail.com>
	<5085370F.80204@parallels.com>
Date: Wed, 31 Oct 2012 08:56:15 +0200
Message-ID: <CAOJsxLGSyBx=VkQ1vjAwYMNgfKR3inWRpkTWTYkWnhzHsVPD_Q@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/slob: Use free_page instead of put_page for
 page-size kmalloc allocations
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Bird <tim.bird@am.sony.com>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>

> On 10/22/2012 04:04 PM, Ezequiel Garcia wrote:
>> When freeing objects, the slob allocator currently free empty pages
>> calling __free_pages(). However, page-size kmallocs are disposed
>> using put_page() instead.
>>
>> It makes no sense to call put_page() for kernel pages that are provided
>> by the object allocator, so we shouldn't be doing this ourselves.
>>
>> This is based on:
>> commit d9b7f22623b5fa9cc189581dcdfb2ac605933bf4
>> Author: Glauber Costa <glommer@parallels.com>

On Mon, Oct 22, 2012 at 3:07 PM, Glauber Costa <glommer@parallels.com> wrote:
> Acked-by: Glauber Costa <glommer@parallels.com>

Applied, thanks Ezequiel!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
