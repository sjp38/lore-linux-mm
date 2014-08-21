Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6AF796B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 16:58:22 -0400 (EDT)
Received: by mail-qg0-f51.google.com with SMTP id a108so9239590qge.38
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 13:58:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m6si40036890qao.36.2014.08.21.13.58.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Aug 2014 13:58:21 -0700 (PDT)
Date: Thu, 21 Aug 2014 16:57:27 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] [v3] warn on performance-impacting configs aka.
 TAINT_PERFORMANCE
Message-ID: <20140821205727.GA7200@redhat.com>
References: <20140821202424.7ED66A50@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140821202424.7ED66A50@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com, peterz@infradead.org, mingo@redhat.com, ak@linux.intel.com, tim.c.chen@linux.intel.com, akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, linux-mm@kvack.org, kirill@shutemov.name, lauraa@codeaurora.org

On Thu, Aug 21, 2014 at 01:24:24PM -0700, Dave Hansen wrote:

 > Changes from v2:
 >  * remove tainting and stack track

...

 > diff -puN include/linux/kernel.h~taint-performance include/linux/kernel.h
 > --- a/include/linux/kernel.h~taint-performance	2014-08-19 11:38:07.424005355 -0700
 > +++ b/include/linux/kernel.h	2014-08-19 11:38:20.960615904 -0700
 > @@ -471,6 +471,7 @@ extern enum system_states {
 >  #define TAINT_OOT_MODULE		12
 >  #define TAINT_UNSIGNED_MODULE		13
 >  #define TAINT_SOFTLOCKUP		14
 > +#define TAINT_PERFORMANCE		15
 >  
 >  extern const char hex_asc[];
 >  #define hex_asc_lo(x)	hex_asc[((x) & 0x0f)]
 > diff -puN kernel/panic.c~taint-performance kernel/panic.c
 > --- a/kernel/panic.c~taint-performance	2014-08-19 11:38:28.928975233 -0700
 > +++ b/kernel/panic.c	2014-08-20 09:56:29.528471033 -0700
 > @@ -225,6 +225,7 @@ static const struct tnt tnts[] = {
 >  	{ TAINT_OOT_MODULE,		'O', ' ' },
 >  	{ TAINT_UNSIGNED_MODULE,	'E', ' ' },
 >  	{ TAINT_SOFTLOCKUP,		'L', ' ' },
 > +	{ TAINT_PERFORMANCE,		'Q', ' ' },

You don't need these any more.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
