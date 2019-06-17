Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35016C31E58
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:20:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03FDB2084D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:20:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03FDB2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 899908E0004; Mon, 17 Jun 2019 08:20:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 821738E0001; Mon, 17 Jun 2019 08:20:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E9FA8E0004; Mon, 17 Jun 2019 08:20:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19ED98E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:20:52 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id s18so4592791wru.16
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:20:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=vRYAGxaAM1x7I4LWg1pgAKw5/xd0/TFo3Lt+Xd3tJPU=;
        b=hfgFLfE9B5ka7sD8ppECKf7kzevxAEqkKATJbbeTiWKrHciHq9mKuOespoiFnTtSTw
         yeZM2K9hbO3BN3ebbvKpWGl2zBAJjodHI67ZG9Zghe1cSzrfsXg/sOvxwSUe97xQPaUV
         NW7fEMsnSE0v0RsAJs4z01jDpPG7j9xY20qXXuEmbqG/xycs/DNYBaWnXNJFPJUVTsxn
         /aoJ+6BbolX8AtzLauMSKaoA4g++ZEH2Oy6RsicPJBtPGWcLj73MPuSJ8Ug3bK3EoMoK
         VCPVR7/qSJwZDmpASw4Mp16SprzwZZDC7/Ge9TD7f0M9pZpnv3RAPqNFxCWsRtDthJue
         2RJw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAUnT/OcBiNNrPskvxw/d/q5wiXLNTCM/9LvNz3xLpHt84LY86X4
	fsfNRxA/6uwqu2+ILVAl1/MXCbkDFYtEOPGHFRvjS68vlN8DJma7K0yl+RPYKyuT/EOcF+ZerIx
	m814fqmv4nA9ogb/4C++M3BhM94aaxa0jCEUB7qJcnxcam/3KKx34p49ZVYDNnGVbAg==
X-Received: by 2002:adf:9dcc:: with SMTP id q12mr7110229wre.6.1560774051694;
        Mon, 17 Jun 2019 05:20:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRXYHWnRyUz7ff8sWJYb9tcgz5wgAg92R1QmKTtDO8Kyc7B1OkTwQoMkFE7oOdtsRiuTHG
X-Received: by 2002:adf:9dcc:: with SMTP id q12mr7110153wre.6.1560774050783;
        Mon, 17 Jun 2019 05:20:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774050; cv=none;
        d=google.com; s=arc-20160816;
        b=EndGMP8siMKsZbTcyaD3DfoJQzMHwCG9DTdF1re3j6kdFAbe7cFOl1/+4xjfR39t/D
         XZs79/+PdOntUMMMgimd54JyOS+/tcLEZHd3H3K/n9rrlhWyCNCyljYGi3vilG/9L2zI
         Q5FRNjYM0FRK9wy/2HK3jabbdMKbGeXQeFyufcxdQYHHPWGp4pZAirX5Tu+k17QnlRU3
         pkNuJ9bOhWnU19pL5uSsgTkgXY6K2F4n4zyLLf4REYSXa45zPZBdsWPOL+ua6Oqme2Iu
         K96J3N1JruYfAFytGH9EYHmld2F3Ed1H70y42a32d2R+p5hRJEwcp0h2bRxX3Au7L3e2
         n+9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=vRYAGxaAM1x7I4LWg1pgAKw5/xd0/TFo3Lt+Xd3tJPU=;
        b=y63oLa9I6lhQWkSfffZ5ojqV5YN5g5vpHLLR25Hfr+4dD7qr1+WcbVuqkk6nQlyH1F
         2ZceoH93XZnVV5uYagCckDn65zUIgEqTiXUzApo/YkhlH+f2BK38tLqauobDn1Zp+Nwn
         cjAZd64masQ4x0gsunsuNVj1b+M+NmniVkOGPnwJUCm/MzwrzgJBmP9ewTBpagFoDKK5
         inSDwp+fNpVTDFysHSHZi4VhhZVjcSwPgBTunS6xgb2GzrdmLryoZX3xOar9lMcj+i9Z
         /sqaDa+ltGf3dKA2tSWFTlRYTcxwJdvC/z50KrraIu3OQ1+uDU+ZsMbceLUXfZqMIJ6y
         6C0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id d67si365865wmf.80.2019.06.17.05.20.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 17 Jun 2019 05:20:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from [5.158.153.52] (helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hcqcr-0006q9-JE; Mon, 17 Jun 2019 14:20:41 +0200
Date: Mon, 17 Jun 2019 14:20:40 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Florian Weimer <fweimer@redhat.com>
cc: Dave Martin <Dave.Martin@arm.com>, Yu-cheng Yu <yu-cheng.yu@intel.com>, 
    x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, 
    Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, 
    linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 
    linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, 
    Andy Lutomirski <luto@amacapital.net>, 
    Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>, 
    Cyrill Gorcunov <gorcunov@gmail.com>, 
    Dave Hansen <dave.hansen@linux.intel.com>, 
    Eugene Syromiatnikov <esyr@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, 
    Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, 
    Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, 
    Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, 
    Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, 
    Randy Dunlap <rdunlap@infradead.org>, 
    "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
    Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an
 ELF file
In-Reply-To: <87imt4jwpt.fsf@oldenburg2.str.redhat.com>
Message-ID: <alpine.DEB.2.21.1906171418220.1854@nanos.tec.linutronix.de>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>        <20190606200646.3951-23-yu-cheng.yu@intel.com>        <20190607180115.GJ28398@e103592.cambridge.arm.com>        <94b9c55b3b874825fda485af40ab2a6bc3dad171.camel@intel.com>       
 <87lfy9cq04.fsf@oldenburg2.str.redhat.com>        <20190611114109.GN28398@e103592.cambridge.arm.com>        <031bc55d8dcdcf4f031e6ff27c33fd52c61d33a5.camel@intel.com>        <20190612093238.GQ28398@e103592.cambridge.arm.com>
 <87imt4jwpt.fsf@oldenburg2.str.redhat.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 17 Jun 2019, Florian Weimer wrote:
> * Dave Martin:
> > On Tue, Jun 11, 2019 at 12:31:34PM -0700, Yu-cheng Yu wrote:
> >> We can probably check PT_GNU_PROPERTY first, and fallback (based on ld-linux
> >> version?) to PT_NOTE scanning?
> >
> > For arm64, we can check for PT_GNU_PROPERTY and then give up
> > unconditionally.
> >
> > For x86, we would fall back to PT_NOTE scanning, but this will add a bit
> > of cost to binaries that don't have NT_GNU_PROPERTY_TYPE_0.  The ld.so
> > version doesn't tell you what ELF ABI a given executable conforms to.
> >
> > Since this sounds like it's largely a distro-specific issue, maybe there
> > could be a Kconfig option to turn the fallback PT_NOTE scanning on?
> 
> I'm worried that this causes interop issues similarly to what we see
> with VSYSCALL today.  If we need both and a way to disable it, it should
> be something like a personality flag which can be configured for each
> process tree separately.  Ideally, we'd settle on one correct approach
> (i.e., either always process both, or only process PT_GNU_PROPERTY) and
> enforce that.

Chose one and only the one which makes technically sense and is not some
horrible vehicle.

Everytime we did those 'oh we need to make x fly workarounds' we regretted
it sooner than later.

Thanks,

	tglx

