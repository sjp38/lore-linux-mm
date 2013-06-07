Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 46E586B0031
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 13:09:38 -0400 (EDT)
Message-ID: <51B213CB.8070102@yandex-team.ru>
Date: Fri, 07 Jun 2013 21:09:31 +0400
From: Roman Gushchin <klamm@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: slub: slab order on multi-processor machines
References: <51B1A04B.7030003@yandex-team.ru> <0000013f1efbaa4f-6039ad3e-286e-4486-8b7e-7b0331edf990-000000@email.amazonses.com>
In-Reply-To: <0000013f1efbaa4f-6039ad3e-286e-4486-8b7e-7b0331edf990-000000@email.amazonses.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: penberg@kernel.org, mpm@selenic.com, yanmin.zhang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07.06.2013 18:12, Christoph Lameter wrote:
> On Fri, 7 Jun 2013, Roman Gushchin wrote:
>
>> As I understand, the idea was to make kernel allocations cheaper by reducing
>> the total
>> number of page allocations (allocating 1 page with order 3 is cheaper than
>> allocating
>> 8 1-ordered pages).
>
> Its also affecting allocator speed. By having less page structures to
> manage the metadata effort is reduced. By having more objects in a page
> the fastpath of slub is more likely to be used (Visible in allocator
> benchmarks). Slub can fall back dynamically to order 0 pages if necessary.
> So it can take opportunistically take advantage of contiguous pages.

Thank you for clarification!

May be it's reasonable to fall back to order 0 pages if it's not possible
to allocate new large page without direct compaction?
I'll try to perform some tests here.

Regards,
Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
