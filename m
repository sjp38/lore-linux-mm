Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8950E6B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 17:03:53 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id rd3so14699249pab.26
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 14:03:53 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id qo10si38046623pac.130.2014.08.21.14.03.49
        for <linux-mm@kvack.org>;
        Thu, 21 Aug 2014 14:03:50 -0700 (PDT)
Message-ID: <53F65EB3.5060209@sr71.net>
Date: Thu, 21 Aug 2014 14:03:47 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH] [v3] warn on performance-impacting configs aka. TAINT_PERFORMANCE
References: <20140821202424.7ED66A50@viggo.jf.intel.com> <20140821205727.GA7200@redhat.com>
In-Reply-To: <20140821205727.GA7200@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com, peterz@infradead.org, mingo@redhat.com, ak@linux.intel.com, tim.c.chen@linux.intel.com, akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, linux-mm@kvack.org, kirill@shutemov.name, lauraa@codeaurora.org

On 08/21/2014 01:57 PM, Dave Jones wrote:
>  > diff -puN kernel/panic.c~taint-performance kernel/panic.c
>  > --- a/kernel/panic.c~taint-performance	2014-08-19 11:38:28.928975233 -0700
>  > +++ b/kernel/panic.c	2014-08-20 09:56:29.528471033 -0700
>  > @@ -225,6 +225,7 @@ static const struct tnt tnts[] = {
>  >  	{ TAINT_OOT_MODULE,		'O', ' ' },
>  >  	{ TAINT_UNSIGNED_MODULE,	'E', ' ' },
>  >  	{ TAINT_SOFTLOCKUP,		'L', ' ' },
>  > +	{ TAINT_PERFORMANCE,		'Q', ' ' },
> 
> You don't need these any more.

Bah, thanks for catching that.  I'll wait a bit for any other comments
and send out a fixed version.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
