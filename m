Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D195C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 20:23:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 546882085A
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 20:23:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="P/scPxgJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 546882085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E38B06B0003; Wed, 26 Jun 2019 16:23:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE91F8E0005; Wed, 26 Jun 2019 16:23:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD7698E0002; Wed, 26 Jun 2019 16:23:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 94FB36B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 16:23:38 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f25so82029pfk.14
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 13:23:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=muTYyZgRfl/88mIFAVs1e5kjaDnXa1/tEbRZdzaGsjo=;
        b=s10SItwuqt7zuYbHvBAtFt8JyiLYQcYZjmF+Nxnvj8wDA0D0laVGGVkWEObSciG8up
         amKRMejN/YYINPyPMr0It2P6FhheVCTj7BGfsY8prjBvZj6T06xU0RWxtx7tnrj9qHXC
         hXAra8QApNEhjOxRok2VdM4At+EwbyLeVLZZyyjylb532VYan32bmJVOq7WShntAHCXY
         5PN8xuNqbPyInJTiHEwNG0WPTVMUgrtI4Uvisq0lnVbQVmJKxZ20ZlKhye/4mBVowfyj
         EpKdQFFuUgMojBiK9l9+N2Jo1NJkmwD26P9ZZ6c38EKtxSRxwdtDCw+3Dj1JtayTzaQs
         dbwQ==
X-Gm-Message-State: APjAAAWTo+tzP8+1VBJ37d5C1pSdCZpIrs8RwZWttgAsCekpKr7RG8Qm
	1kq1y+aSWb30cK6nVauc2DtsEABnbN8Y1FNOAfSMPmIuIDy1gU83CLV2bCJjAesdgo7CUwxFqXW
	uzSFNfjirNjbJajlx4nAHPWZK1u0CSLTZ1JBcnjL+tlGttslB36rmCrw18YcsYX6HGg==
X-Received: by 2002:a63:a50a:: with SMTP id n10mr4410406pgf.200.1561580618102;
        Wed, 26 Jun 2019 13:23:38 -0700 (PDT)
X-Received: by 2002:a63:a50a:: with SMTP id n10mr4410331pgf.200.1561580616988;
        Wed, 26 Jun 2019 13:23:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561580616; cv=none;
        d=google.com; s=arc-20160816;
        b=YDzEyBlR586EylYH644rZibksTkKsSDjl+b7tjUWfzhnsXUgDSw/G+OPx2Q9Uy7zFW
         DyeZei0sdUoi2jFnPUFKbyMlJTbhC1TehlkcYTNZlKsWD0Bc0ZGgB0uPeeA7GN1w+e15
         Jf5lM9VN61y1ZCHGIDLx9RW6q0u2BGStOOaZCb9KniZBQfrJmZGz0KatZNN3sMWdugKU
         z7Aeflodq3238oxOdFEWu2BaX6ymJrCpDpWPBTGsHkehVFh1RI1jUbXVt73PGDg717ez
         yETCZE5pvuLDEtR8b6op74mH4blLQZ8uWbSb30WJNlES4TjnHCwGWKP77zzUEkMQI1YT
         3HzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date
         :dkim-signature;
        bh=muTYyZgRfl/88mIFAVs1e5kjaDnXa1/tEbRZdzaGsjo=;
        b=yeotBS/9ljEfSqrGvmFL598TXpYnWbdXYdiepJOXyHjiPFuErSPVxLMYAbhSp9E2xH
         a7ZsbtZ/Y0ggSgP5Ob5EKFiMLWLLV65SsmOf/a91I+II4hZoFTe2HKRtNIgovBJo+5Cu
         T+1CIABDwIJB4mXsYO3m8Fn5k2FBXMZgNoaNprNPPVhZs79PXwKyYVNz8LzyQiNNfbuh
         RDez/qB4ggrTHjPJs51u1HEJSP/AHF4xlhFOw1OrLCuE1nHcu5cfIbTNymNM1HpesuLb
         C+0fWvbdvyL36VKgk2UUvO5RCmL5Iw+kVGw/aortxr3t6+NfwVXFYRaM1+v2+JCK8Yzd
         blEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="P/scPxgJ";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d126sor73150pfa.39.2019.06.26.13.23.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 13:23:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="P/scPxgJ";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to;
        bh=muTYyZgRfl/88mIFAVs1e5kjaDnXa1/tEbRZdzaGsjo=;
        b=P/scPxgJwc5farJAuIHByPDzINLlpr/5LkI5Tz6+ai7Kj6UtSOEPgw/pAPCJhurLrb
         ZQ0eibdOJyW6g/M6uGhLEpiSkeN4GKncEIPlWE3Fza8R3XpnXSMtSrmpdDBC74OQmyy4
         JbJbO0Oym2obl8mXnsLlMjJEvdkuFyPhp8y6U=
X-Google-Smtp-Source: APXvYqzqyJA+jcyGndR/DWIwWD+l17OEz6109S6f0/nlZGL0QzbHiaGQY6O+Vl51hxMnbBXTaxumMg==
X-Received: by 2002:a65:5003:: with SMTP id f3mr4639488pgo.75.1561580616571;
        Wed, 26 Jun 2019 13:23:36 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id d4sm2593109pju.19.2019.06.26.13.23.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 26 Jun 2019 13:23:35 -0700 (PDT)
Date: Wed, 26 Jun 2019 13:23:34 -0700
From: Kees Cook <keescook@chromium.org>
To: Qian Cai <cai@lca.pw>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Alexander Potapenko <glider@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Michal Hocko <mhocko@kernel.org>, James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>,
	linux-mm@kvack.org, linux-security-module@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	clang-built-linux@googlegroups.com
Subject: Re: [PATCH v8 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <201906261303.020ADC9@keescook>
References: <20190626121943.131390-1-glider@google.com>
 <20190626121943.131390-2-glider@google.com>
 <1561572949.5154.81.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1561572949.5154.81.camel@lca.pw>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 02:15:49PM -0400, Qian Cai wrote:
> On Wed, 2019-06-26 at 14:19 +0200, Alexander Potapenko wrote:
> > Both init_on_alloc and init_on_free default to zero, but those defaults
> > can be overridden with CONFIG_INIT_ON_ALLOC_DEFAULT_ON and
> > CONFIG_INIT_ON_FREE_DEFAULT_ON.
> > [...]
> > +static int __init early_init_on_alloc(char *buf)
> > +{
> > +	int ret;
> > +	bool bool_result;
> > +
> > +	if (!buf)
> > +		return -EINVAL;
> > +	ret = kstrtobool(buf, &bool_result);
> > +	if (bool_result)
> > +		static_branch_enable(&init_on_alloc);
> > +	else
> > +		static_branch_disable(&init_on_alloc);
> > +	return ret;
> > +}
> > +early_param("init_on_alloc", early_init_on_alloc);
> 
> Do those really necessary need to be static keys?
> 
> Adding either init_on_free=0 or init_on_alloc=0 to the kernel cmdline will
> generate a warning with kernels built with clang.
> 
> [    0.000000] static_key_disable(): static key 'init_on_free+0x0/0x4' used
> before call to jump_label_init()
> [    0.000000] WARNING: CPU: 0 PID: 0 at ./include/linux/jump_label.h:317
> early_init_on_free+0x1c0/0x200
> [    0.000000] Modules linked in:
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 5.2.0-rc6-next-20190626+
> #9
> [    0.000000] pstate: 60000089 (nZCv daIf -PAN -UAO)

I think the issue here is that arm64 doesn't initialize static keys
early enough.

init/main.c has the general case:

asmlinkage __visible void __init start_kernel(void)
{
        ...
        setup_arch(&command_line);
        ...
        smp_prepare_boot_cpu();
        ...
        /* parameters may set static keys */
        jump_label_init();
        parse_early_param();
        ...
}

however, x86 does even earlier early params in setup_arch():

void __init setup_arch(char **cmdline_p)
{
        ...
        jump_label_init();
        ...
        parse_early_param();
        ...
}

arm64 does similar very early early params in setup_arch()[1] too,
but not jump_label_init() which is too late in smp_prepare_boot_cpu():

void __init setup_arch(char **cmdline_p)
{
        ...
        parse_early_param();
        ...
}

void __init smp_prepare_boot_cpu(void)
{
        ...
        jump_label_init();
        ...
}

I can send a patch to fix this...

-Kees

[1] since efd9e03facd07 ("arm64: Use static keys for CPU features")

> [    0.000000] pc : early_init_on_free+0x1c0/0x200
> [    0.000000] lr : early_init_on_free+0x1c0/0x200
> [    0.000000] sp : ffff100012c07df0
> [    0.000000] x29: ffff100012c07e20 x28: ffff1000110a01ec 
> [    0.000000] x27: 000000000000005f x26: ffff100011716cd0 
> [    0.000000] x25: ffff100010d36166 x24: ffff100010d3615d 
> [    0.000000] x23: ffff100010d364b5 x22: ffff1000117164a0 
> [    0.000000] x21: 0000000000000000 x20: 0000000000000000 
> [    0.000000] x19: 0000000000000000 x18: 000000000000002e 
> [    0.000000] x17: 000000000000000f x16: 0000000000000040 
> [    0.000000] x15: 0000000000000000 x14: 6c61632065726f66 
> [    0.000000] x13: 6562206465737520 x12: 273478302f307830 
> [    0.000000] x11: 0000000000000000 x10: 0000000000000000 
> [    0.000000] x9 : 0000000000000000 x8 : 0000000000000000 
> [    0.000000] x7 : 6d756a206f74206c x6 : ffff100014426625 
> [    0.000000] x5 : ffff100012c07b28 x4 : 0000000000000007 
> [    0.000000] x3 : ffff1000101aadf4 x2 : 0000000000000001 
> [    0.000000] x1 : 0000000000000001 x0 : 000000000000005d 
> [    0.000000] Call trace:
> [    0.000000]  early_init_on_free+0x1c0/0x200
> [    0.000000]  do_early_param+0xd0/0x104
> [    0.000000]  parse_args+0x1f0/0x524
> [    0.000000]  parse_early_param+0x70/0x8c
> [    0.000000]  setup_arch+0xa8/0x268
> [    0.000000]  start_kernel+0x80/0x560
> 

-- 
Kees Cook

