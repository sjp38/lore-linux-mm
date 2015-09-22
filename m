Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 76AAB6B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 15:53:50 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so177515754wic.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 12:53:50 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id u9si4435914wjx.196.2015.09.22.12.53.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 22 Sep 2015 12:53:48 -0700 (PDT)
Date: Tue, 22 Sep 2015 21:53:08 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 05/26] x86, pkey: add PKRU xsave fields and data
 structure(s)
In-Reply-To: <20150916174905.0ECA529B@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1509222152300.5606@nanos>
References: <20150916174903.E112E464@viggo.jf.intel.com> <20150916174905.0ECA529B@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 16 Sep 2015, Dave Hansen wrote:
> --- a/arch/x86/kernel/fpu/xstate.c~pkeys-03-xsave	2015-09-16 10:48:13.340060126 -0700
> +++ b/arch/x86/kernel/fpu/xstate.c	2015-09-16 10:48:13.344060307 -0700
> @@ -23,6 +23,8 @@ static const char *xfeature_names[] =
>  	"AVX-512 opmask"		,
>  	"AVX-512 Hi256"			,
>  	"AVX-512 ZMM_Hi256"		,
> +	"unknown xstate feature (8)"	,

It's not unknown. It's PT, right?

> +	"Protection Keys User registers",
>  	"unknown xstate feature"	,
>  };

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
