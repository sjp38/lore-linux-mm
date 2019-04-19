Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17A48C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 11:07:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6AA121908
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 11:07:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="R9Rm0/wR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6AA121908
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 382676B0007; Fri, 19 Apr 2019 07:07:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 332ED6B0008; Fri, 19 Apr 2019 07:07:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 224A86B000A; Fri, 19 Apr 2019 07:07:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id B281D6B0007
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 07:07:07 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id i27so896494ljb.3
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 04:07:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=68TXNoe1+xM5JQ/u4eCzVp2M/QEoCEujrVbcsex5r28=;
        b=CM0WYooNNKwRB6In4/SHNqKCceB4NbDpC//wmq6lEAdeCDimaZvTo3kdtj5JNmTf/h
         NcSbWqcN1N3xHyKEWKly6Lfjxz6PjwVSPzsysT8X6JUAb9aekNcELwLeUdVAE6lrlmZE
         kxMIzz7X3YT0/EFFg/BWtrXffNx1Gs+6Au5U10ytiMhKEXVt7efvZjQSK+Cf0DuFSBA7
         OmLmro4NUadm2VRco+7g9U6JtBpknveGGStlzc/UC/HlzyFNDAyboF2DKULdtL5mHDHN
         K5LVI3O/OwMFjT9tp9yUnTSeaC0bzlPi43ws0xXAX4+Ab5AOjMVJInu190BVDSavvWaL
         0mYQ==
X-Gm-Message-State: APjAAAXxyDw0d4QUyfV5xIYTHnA4KxXA6b7ebgzQ9Shf7jqJYCTcfM5w
	JecgBdlpj0N4HPIYrRpGQrGMkY1N4jSXHu1uktUR31wWUxWVfaWvOAjGMhEIXBUjO285OJeASzI
	TpHDPz+A/ZY96jS7ZCBGepEBbXCaT2OsxZ14IAqwjPCcC7JQJa++hDqZKYghm91Fhxw==
X-Received: by 2002:ac2:560b:: with SMTP id v11mr1904416lfd.151.1555672026849;
        Fri, 19 Apr 2019 04:07:06 -0700 (PDT)
X-Received: by 2002:ac2:560b:: with SMTP id v11mr1904368lfd.151.1555672025866;
        Fri, 19 Apr 2019 04:07:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555672025; cv=none;
        d=google.com; s=arc-20160816;
        b=YQmFsz7k43/qZq2GRipMvPPfqdJkVq42n9d5WgoTPqlxsvEN5iEeqcTPz+REOgCZ9j
         20dtIKHfv2LbeojYLqQjSk3yYRuJFy7jZT9oNsn2EFqYwai3qUuK295mySeK4idVNV84
         4Q7aIQFYsBUH0sBU/C9eYH/I+Ws9+7LEejQjIqOfoGgkWQP1URc+h5VkdMQ9acz6N7/P
         w4pFVwCTQmeMCRf8HNXTJWKGq/OfIGOlHWXb5/f7m62Pf/FVVOE4iYcvTr47r/0GyzYn
         ZxtceRIz/cEewziUlR7CZgwOCiSHqB8H6k4K06bqJ64UPUg3dUzSZckaxHDDiJKvw2AN
         X8vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=68TXNoe1+xM5JQ/u4eCzVp2M/QEoCEujrVbcsex5r28=;
        b=MjA1YBYMOgSjq2Gu4c8IHIUcgI2y4WTXN5TzaeyMBrlci1eOgZX42txNzry3wBOZos
         bAX5jyzS9V6rEtck0lkcMWSH2HmxsiAJW9J2ussOVY/++FWzsBwgSPQPdjR7iLOIYpSj
         /HcNnLa6W4WJTjOJFnKPTfBxDbpFu/YI3pFeMfeDS1kR2lWJoeHJFsuKkqoJw3cit61R
         xgZwmCjIDsEwG5XCFebi4ZwP2unD8Mgl2cIcKDUHB0ss+rDYQMSRbalD5Kpbpwd+qHtn
         0yaz/EI6HNUHRZUk5uiBDkImNGYR3ui/bFM45Jx/Goqhu3xqfB7dFLwET8aE7QsLfqyJ
         Orhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="R9Rm0/wR";
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f28sor1309325lfk.57.2019.04.19.04.07.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Apr 2019 04:07:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="R9Rm0/wR";
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=68TXNoe1+xM5JQ/u4eCzVp2M/QEoCEujrVbcsex5r28=;
        b=R9Rm0/wRIy6/5g6TMnj5RvD7oL5Z51FEI8yYWeCQp8SKio/6jsveYvyBotprga0fIT
         GxNPo/Io7TAGAgnz7SMXSJsNXlxRqbeEHGIho8101KfEky4Y9jZqKRpr4BEl69Ng0A1N
         nqsOsy3vTkt/jjsjqtaAl4GJGtkfm1EG7hQ9dFztX9Kfkss2+7a9l0ZrZGeAqWCl1Xnm
         iQixh7ALVZDnZ7NQw2ekj0797Z6AsouXXwwoY3mpiOknEvbljywaoBV5k8RD5DLEKgl/
         A7iTZxc3jlZ21jEejuFSgq/VPygySuNRuKy5rJlfKoMiCasMhg84QnvCgZvH311j/42E
         n5pg==
X-Google-Smtp-Source: APXvYqz5m5b6ag++LflCKpSfnwHSA+V0arpZSnsFvvtqZcfLD+mGsb6oWAHL2itIJoeyMsn0oGqd2g==
X-Received: by 2002:a19:f50e:: with SMTP id j14mr1081673lfb.11.1555672025313;
        Fri, 19 Apr 2019 04:07:05 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id g79sm992924lje.25.2019.04.19.04.07.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 19 Apr 2019 04:07:04 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Fri, 19 Apr 2019 13:06:56 +0200
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/1] lib/test_vmalloc: do not create cpumask_t variable
 on stack
Message-ID: <20190419110656.znni5hdojf42iq5k@pc636>
References: <20190418193925.9361-1-urezki@gmail.com>
 <20190418151033.9e46ec06c1d7482e6dee14bc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190418151033.9e46ec06c1d7482e6dee14bc@linux-foundation.org>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 03:10:33PM -0700, Andrew Morton wrote:
> On Thu, 18 Apr 2019 21:39:25 +0200 "Uladzislau Rezki (Sony)" <urezki@gmail.com> wrote:
> 
> > On my "Intel(R) Xeon(R) W-2135 CPU @ 3.70GHz" system(12 CPUs)
> > i get the warning from the compiler about frame size:
> > 
> > <snip>
> > warning: the frame size of 1096 bytes is larger than 1024 bytes
> > [-Wframe-larger-than=]
> > <snip>
> > 
> > the size of cpumask_t depends on number of CPUs, therefore just
> > make use of cpumask_of() in set_cpus_allowed_ptr() as a second
> > argument.
> > 
> > ...
> L
> > --- a/lib/test_vmalloc.c
> > +++ b/lib/test_vmalloc.c
> > @@ -383,14 +383,14 @@ static void shuffle_array(int *arr, int n)
> >  static int test_func(void *private)
> >  {
> >  	struct test_driver *t = private;
> > -	cpumask_t newmask = CPU_MASK_NONE;
> >  	int random_array[ARRAY_SIZE(test_case_array)];
> >  	int index, i, j, ret;
> >  	ktime_t kt;
> >  	u64 delta;
> >  
> > -	cpumask_set_cpu(t->cpu, &newmask);
> > -	set_cpus_allowed_ptr(current, &newmask);
> > +	ret = set_cpus_allowed_ptr(current, cpumask_of(t->cpu));
> > +	if (ret < 0)
> > +		pr_err("Failed to set affinity to %d CPU\n", t->cpu);
> >  
> >  	for (i = 0; i < ARRAY_SIZE(test_case_array); i++)
> >  		random_array[i] = i;
> 
> lgtm.
> 
> While we're in there...
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: lib/test_vmalloc.c:test_func(): eliminate local `ret'
> 
> Local 'ret' is unneeded and was poorly named: the variable `ret' generally
> means the "the value which this function will return".
> 
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Uladzislau Rezki <urezki@gmail.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Thomas Garnier <thgarnie@google.com>
> Cc: Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: Joel Fernandes <joelaf@google.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: Tejun Heo <tj@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  lib/test_vmalloc.c |    8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
> 
> --- a/lib/test_vmalloc.c~a
> +++ a/lib/test_vmalloc.c
> @@ -384,12 +384,11 @@ static int test_func(void *private)
>  {
>  	struct test_driver *t = private;
>  	int random_array[ARRAY_SIZE(test_case_array)];
> -	int index, i, j, ret;
> +	int index, i, j;
>  	ktime_t kt;
>  	u64 delta;
>  
> -	ret = set_cpus_allowed_ptr(current, cpumask_of(t->cpu));
> -	if (ret < 0)
> +	if (set_cpus_allowed_ptr(current, cpumask_of(t->cpu)) < 0)
>  		pr_err("Failed to set affinity to %d CPU\n", t->cpu);
>  
>  	for (i = 0; i < ARRAY_SIZE(test_case_array); i++)
> @@ -415,8 +414,7 @@ static int test_func(void *private)
>  
>  		kt = ktime_get();
>  		for (j = 0; j < test_repeat_count; j++) {
> -			ret = test_case_array[index].test_func();
> -			if (!ret)
> +			if (!test_case_array[index].test_func())
>  				per_cpu_test_data[t->cpu][index].test_passed++;
>  			else
>  				per_cpu_test_data[t->cpu][index].test_failed++;
> _
> 
Agree with your slight update.

Thank you!

--
Vlad Rezki

