Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 13B776B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 18:58:01 -0500 (EST)
Received: by ghrr18 with SMTP id r18so754153ghr.14
        for <linux-mm@kvack.org>; Wed, 08 Feb 2012 15:58:00 -0800 (PST)
Date: Thu, 9 Feb 2012 00:57:55 +0100
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH] selftests: Launch individual selftests from the main
 Makefile
Message-ID: <20120208235752.GE25473@somewhere.redhat.com>
References: <20120205081555.GA2249@darkstar.redhat.com>
 <20120206155340.b9075240.akpm@linux-foundation.org>
 <20120208034055.GA23894@somewhere.redhat.com>
 <20120208152022.1016434f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120208152022.1016434f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Young <dyoung@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, penberg@kernel.org, fengguang.wu@intel.com, cl@linux.com

On Wed, Feb 08, 2012 at 03:20:22PM -0800, Andrew Morton wrote:
> On Wed, 8 Feb 2012 04:40:59 +0100
> Frederic Weisbecker <fweisbec@gmail.com> wrote:
> 
> > Drop the run_tests script and launch the selftests by calling
> > "make run_tests" from the selftests top directory instead. This
> > delegates to the Makefile on each selftest directory where it
> > is decided how to launch the local test.
> > 
> > This drops the need to add each selftest directory on the
> > now removed "run_tests" top script.
> 
> Looks good.
> 
> I did
> 
> 	cd tools/testing/selftests
> 	make run_tests
> 
> and it didn't work.  This?
> 
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: selftests/Makefile: make `run_tests' depend on `all'
> 
> So a "make run_tests" will build the tests before trying to run them.
> 
> Cc: Frederic Weisbecker <fweisbec@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  tools/testing/selftests/Makefile |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN tools/testing/selftests/Makefile~a tools/testing/selftests/Makefile
> --- a/tools/testing/selftests/Makefile~a
> +++ a/tools/testing/selftests/Makefile
> @@ -5,7 +5,7 @@ all:
>  		make -C $$TARGET; \
>  	done;
>  
> -run_tests:
> +run_tests: all
>  	for TARGET in $(TARGETS); do \
>  		make -C $$TARGET run_tests; \
>  	done;

Yeah that's good. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
