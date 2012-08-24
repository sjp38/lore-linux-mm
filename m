Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 8EF866B002B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 12:40:23 -0400 (EDT)
Received: by obhx4 with SMTP id x4so5653589obh.14
        for <linux-mm@kvack.org>; Fri, 24 Aug 2012 09:40:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <000001395978f794-7569c405-1955-4e20-ad74-6e60ee4efcdc-000000@email.amazonses.com>
References: <1345824303-30292-1-git-send-email-js1304@gmail.com>
	<1345824303-30292-2-git-send-email-js1304@gmail.com>
	<00000139596a800b-875d7863-23ac-44a5-8710-ea357f3df8a8-000000@email.amazonses.com>
	<CAAmzW4ORnSLMdhVPmYPpeEJ=P1rrpz1LOibOYWQJgOYQxmDhuA@mail.gmail.com>
	<000001395978f794-7569c405-1955-4e20-ad74-6e60ee4efcdc-000000@email.amazonses.com>
Date: Sat, 25 Aug 2012 01:40:22 +0900
Message-ID: <CAAmzW4MjPGC+e4FuMO2M+OWLNG3M+FKhX7Qaz+DtedfKLF_S0Q@mail.gmail.com>
Subject: Re: [PATCH 2/2] slub: correct the calculation of the number of cpu
 objects in get_partial_node
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

2012/8/25 Christoph Lameter <cl@linux.com>:
> On Sat, 25 Aug 2012, JoonSoo Kim wrote:
>
>> But, when using "cpu_partial_objects", I have a coding style problem.
>>
>>                 if (kmem_cache_debug(s)
>>                         || cpu_slab_objects + cpu_partial_objects
>>                                                 > s->max_cpu_object / 2)
>>
>> Do you have any good idea?
>
> Not sure what the problem is? The line wrap?

Yes! The line wrap.


                if (kmem_cache_debug(s)
                || cpu_slab_objects + cpu_partial_objects >
s->max_cpu_object / 2)
                        break;

Above example use 82 columns... The line wrapping problem.

                if (kmem_cache_debug(s) ||
                cpu_slab_objects + cpu_partial_objects > s->max_cpu_object / 2)
                        break;

This one use 79 columns, but somehow ugly
because second line start at same column of above line.
Is it okay?


                if (kmem_cache_debug(s)
                        || cpu_slab_objects + cpu_partial_objects
                                                > s->max_cpu_object / 2)
                        break;

Is it the best?
It use 72 columns.
Let me know what is the best method for this situation.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
