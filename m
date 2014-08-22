Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9CE056B0035
	for <linux-mm@kvack.org>; Fri, 22 Aug 2014 12:45:27 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so16310490pde.9
        for <linux-mm@kvack.org>; Fri, 22 Aug 2014 09:45:27 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id pm7si41639137pac.51.2014.08.22.09.45.25
        for <linux-mm@kvack.org>;
        Fri, 22 Aug 2014 09:45:25 -0700 (PDT)
Message-ID: <53F773A2.7040904@sr71.net>
Date: Fri, 22 Aug 2014 09:45:22 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH] [v3] warn on performance-impacting configs aka. TAINT_PERFORMANCE
References: <20140821202424.7ED66A50@viggo.jf.intel.com> <1408725157.4347.14.camel@schen9-DESK>
In-Reply-To: <1408725157.4347.14.camel@schen9-DESK>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com, peterz@infradead.org, mingo@redhat.com, ak@linux.intel.com, akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, linux-mm@kvack.org, kirill@shutemov.name, lauraa@codeaurora.org

On 08/22/2014 09:32 AM, Tim Chen wrote:
>> > +#ifdef CONFIG_DEBUG_OBJECTS_FREE
>> > +	"DEBUG_OBJECTS_FREE",
>> > +#endif
>> > +#ifdef CONFIG_DEBUG_KMEMLEAK
>> > +	"DEBUG_KMEMLEAK",
>> > +#endif
>> > +#ifdef CONFIG_DEBUG_PAGEALLOC
>> > +	"DEBUG_PAGEALLOC",
> I think coverage profiling also impact performance.
> So I sould also put CONFIG_GCOV_KERNEL in the list.

Would CONFIG_GCOV_PROFILE_ALL be the better one to check?  With plain
GCOV_KERNEL, I don't think we will, by default, put the coverage
information in any files and slow them down.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
