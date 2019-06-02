Return-Path: <SRS0=2YS/=UB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C672CC28CC4
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 05:06:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 630882783D
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 05:06:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="I+l433GU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 630882783D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2E636B0003; Sun,  2 Jun 2019 01:06:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDE3D6B0005; Sun,  2 Jun 2019 01:06:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCDB06B0006; Sun,  2 Jun 2019 01:06:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 879956B0003
	for <linux-mm@kvack.org>; Sun,  2 Jun 2019 01:06:15 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id n1so2348049plk.11
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 22:06:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=8FrEn8Oc47oyqvsIyUn+ei84DckXK5ddHX1nKUOQVF0=;
        b=pkosEYqaM3n0k9Li7lx3DxOecJdKKuqnSMrMufS8YDadj4XUKeyqjv/9bAmGJloU37
         GLLqcsmCVw3TibVbuzadKkfJIdQaYt39cDrc0891P7+9m2arJJ4p2PTbFB9buGW0DLEq
         RxN54MyCBUCvzXuqQiZM82xJJCxyHIkEFKwe2BDwhuxymw7ihsZksfSeCsAPpGXQEfby
         YCGNBt6N2+exY/bEH2W2L6MLJN2qOOunH1VTL1mjqXilBfo9HnCtvhztakKSrSEXvc0b
         DNIGjk3o7MbIxpZQtJ7rusMWMtApotk4VI7e43+oe5KPvd0Cp197eELwe7Rti2VGRFW0
         rW/Q==
X-Gm-Message-State: APjAAAWu3xszn0OHdQPUo327iRNmYGN/uxW6fMtPhtcbvRLzi3RqeuSf
	bHHnOB5OyLN5fk5lRal+C++tgA5f6BnAJnzWJKWZvv+fNf/m9wdeQtafOi1aHnj2AgsFUkJ4IKM
	U+WnRm+ed7AL4Djj3+zdrKx9jSvbqNG2TZOWS0p6gzUwaUl9GuKOkDmOskTQ2g/BJOg==
X-Received: by 2002:a63:5d20:: with SMTP id r32mr15451625pgb.393.1559451975066;
        Sat, 01 Jun 2019 22:06:15 -0700 (PDT)
X-Received: by 2002:a63:5d20:: with SMTP id r32mr15451583pgb.393.1559451973693;
        Sat, 01 Jun 2019 22:06:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559451973; cv=none;
        d=google.com; s=arc-20160816;
        b=YLxdaouZ1uRrj2pB7bpFlerw9EWDOdqBx4WYSJudWDpTteppcQXDIAWwkmQz3bx4nV
         8FIoFCqjEwnPg4rGH9V9rSTLZTmKGHCqHF0MvG/18+PUpUvCYwg/1bYpQQnqUs2aHUAT
         yca9ukCnql2cKq/AVNvoTXoFaf2oMbl3QoRfzMdk+NYrIQ7jQH9BiqosAv+jcxghwD3m
         5R25edpxL0hp37hfIiuhyAnT5sepn9KAX+JiE2q9xl/4rQkhb6qxjSDmFjGYQ5ZLFr5F
         pd+YeWg84vWSelXwrFOlTDeq4SoEWhk3RGYnbsz6I6F++JPZYiK6eFx7B6F6JSw9aKUQ
         efQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=8FrEn8Oc47oyqvsIyUn+ei84DckXK5ddHX1nKUOQVF0=;
        b=IspOwEybgQdC61vO/hdSRqlU2ffDLSiibaSYGYcQALZYxY/eT8EQbPuez4HEYMIdwL
         5o5VbsWz2j3G6TWi/jD0TPbjGomXXt8UcLOptoFg7vkmWYLjGYhb91zA89ObjxNy3cNp
         YTf4kYnPfw+AGeOuKVY44N/XRMK/2hFZG1PkJvMN3f76Q7tRYBMxbuhi5rv20+EUviD4
         Nfk3A5S+Ans+snlmCOVUt3cIQww7kuL+Q3UVqnoJZ6DRE2fQK5FRp4xILo2T2TSc868t
         /53GVmQhxDS503pMgoWWgwqvLnaOF24bJGPIwAkjFLMFWC0LHWr9x0DKYBb91tBIxJ7k
         kytw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=I+l433GU;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i125sor12248353pfb.26.2019.06.01.22.06.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 01 Jun 2019 22:06:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=I+l433GU;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=8FrEn8Oc47oyqvsIyUn+ei84DckXK5ddHX1nKUOQVF0=;
        b=I+l433GU6rh5Vh+cXRg2sWftONjf5E0xtYRJR0maMC3On194A0XuFQ8es0fmdrLaO4
         QMulbFvcAdi+pOn8HpskX0ufgW7qoStMxwwMGtpoIzBLU8ImYfubQhLJZlu5J4RYe6TO
         Yim8ter4osHiihcYza518LDlKNV+048cHSWMc=
X-Google-Smtp-Source: APXvYqww51z53Fj+SFur89FkVZvsAjQrEhIV13t8870aGnrYJ2f32X4e6lxRmTKOa2Pc17jm0i7ppA==
X-Received: by 2002:a65:520b:: with SMTP id o11mr20347226pgp.184.1559451973138;
        Sat, 01 Jun 2019 22:06:13 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id x28sm12472404pfo.78.2019.06.01.22.06.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 01 Jun 2019 22:06:12 -0700 (PDT)
Date: Sat, 1 Jun 2019 22:06:10 -0700
From: Kees Cook <keescook@chromium.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: enh <enh@google.com>, Evgenii Stepanov <eugenis@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <201906012156.55E2C45@keescook>
References: <201905211633.6C0BF0C2@keescook>
 <20190522101110.m2stmpaj7seezveq@mbp>
 <CAJgzZoosKBwqXRyA6fb8QQSZXFqfHqe9qO9je5TogHhzuoGXJQ@mail.gmail.com>
 <20190522163527.rnnc6t4tll7tk5zw@mbp>
 <201905221316.865581CF@keescook>
 <20190523144449.waam2mkyzhjpqpur@mbp>
 <201905230917.DEE7A75EF0@keescook>
 <20190523174345.6sv3kcipkvlwfmox@mbp>
 <201905231327.77CA8D0A36@keescook>
 <20190528170244.GF32006@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528170244.GF32006@arrakis.emea.arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 06:02:45PM +0100, Catalin Marinas wrote:
> On Thu, May 23, 2019 at 02:31:16PM -0700, Kees Cook wrote:
> > syzkaller already attempts to randomly inject non-canonical and
> > 0xFFFF....FFFF addresses for user pointers in syscalls in an effort to
> > find bugs like CVE-2017-5123 where waitid() via unchecked put_user() was
> > able to write directly to kernel memory[1].
> > 
> > It seems that using TBI by default and not allowing a switch back to
> > "normal" ABI without a reboot actually means that userspace cannot inject
> > kernel pointers into syscalls any more, since they'll get universally
> > stripped now. Is my understanding correct, here? i.e. exploiting
> > CVE-2017-5123 would be impossible under TBI?
> > 
> > If so, then I think we should commit to the TBI ABI and have a boot
> > flag to disable it, but NOT have a process flag, as that would allow
> > attackers to bypass the masking. The only flag should be "TBI or MTE".
> > 
> > If so, can I get top byte masking for other architectures too? Like,
> > just to strip high bits off userspace addresses? ;)
> 
> Just for fun, hack/attempt at your idea which should not interfere with
> TBI. Only briefly tested on arm64 (and the s390 __TYPE_IS_PTR macro is
> pretty weird ;)):

OMG, this is amazing and bonkers. I love it.

> --------------------------8<---------------------------------
> diff --git a/arch/s390/include/asm/compat.h b/arch/s390/include/asm/compat.h
> index 63b46e30b2c3..338455a74eff 100644
> --- a/arch/s390/include/asm/compat.h
> +++ b/arch/s390/include/asm/compat.h
> @@ -11,9 +11,6 @@
>  
>  #include <asm-generic/compat.h>
>  
> -#define __TYPE_IS_PTR(t) (!__builtin_types_compatible_p( \
> -				typeof(0?(__force t)0:0ULL), u64))
> -
>  #define __SC_DELOUSE(t,v) ({ \
>  	BUILD_BUG_ON(sizeof(t) > 4 && !__TYPE_IS_PTR(t)); \
>  	(__force t)(__TYPE_IS_PTR(t) ? ((v) & 0x7fffffff) : (v)); \
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index e2870fe1be5b..b1b9fe8502da 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -119,8 +119,15 @@ struct io_uring_params;
>  #define __TYPE_IS_L(t)	(__TYPE_AS(t, 0L))
>  #define __TYPE_IS_UL(t)	(__TYPE_AS(t, 0UL))
>  #define __TYPE_IS_LL(t) (__TYPE_AS(t, 0LL) || __TYPE_AS(t, 0ULL))
> +#define __TYPE_IS_PTR(t) (!__builtin_types_compatible_p(typeof(0 ? (__force t)0 : 0ULL), u64))
>  #define __SC_LONG(t, a) __typeof(__builtin_choose_expr(__TYPE_IS_LL(t), 0LL, 0L)) a
> +#ifdef CONFIG_64BIT
> +#define __SC_CAST(t, a)	(__TYPE_IS_PTR(t) \
> +				? (__force t) ((__u64)a & ~(1UL << 55)) \
> +				: (__force t) a)
> +#else
>  #define __SC_CAST(t, a)	(__force t) a
> +#endif
>  #define __SC_ARGS(t, a)	a
>  #define __SC_TEST(t, a) (void)BUILD_BUG_ON_ZERO(!__TYPE_IS_LL(t) && sizeof(t) > sizeof(long))

I'm laughing, I'm crying. Now I have to go look at the disassembly to
see how this actually looks. (I mean, it _does_ solve my specific case
of the waitid() flaw, but wouldn't help with pointers deeper in structs,
etc, though TBI does, I think still help with that. I have to catch back
up on the thread...) Anyway, if it's not too expensive it'd block
reachability for those kinds of flaws.

I wonder what my chances are of actually getting this landed? :)
(Though, I guess I need to find a "VA width" macro instead of a raw 55.)

Thanks for thinking of __SC_CAST() and __TYPE_IS_PTR() together. Really
made my day. :)

-- 
Kees Cook

