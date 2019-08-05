Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 773BCC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 11:58:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B4192086D
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 11:58:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hngqHboW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B4192086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBBC96B0007; Mon,  5 Aug 2019 07:58:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF6586B0008; Mon,  5 Aug 2019 07:58:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6F726B000A; Mon,  5 Aug 2019 07:58:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F32C6B0007
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 07:58:38 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id j81so72045199qke.23
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 04:58:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=e8LeZYKHIbk2Da0fZqUR7a7Js8ma4FkwyhW8sZVdCZk=;
        b=HZ19V6O311kq+j/rAbyDVRhW3kBPgQx9oRY0c7RljMhkjBPrXX/74yH4EVpw87kp+3
         KlXJPVS+dbJmMK43YxXnEmHE26uDSipogi0+FCoc6LebshP/D4CX0C4h1DnSj93arUVt
         GXxCB48EIsFBrxOPez105FVGRi178BEAd5YT7mzVnQjpQvuYPH/bFfshbe0Pc1z5vKi8
         ocmEK1mITcTTlSyWwEH2T7XYjQI1tMheKQf0OCOx8vT0jbXxEBuz/p42HUctWix0IJB5
         8XOPwew4tFT4udbiGEHdixlq/JnWAfvP13ARyPkHdSsXuoNN08ZG8WSqM6sAeGdVdLx2
         zmJQ==
X-Gm-Message-State: APjAAAW22cA+a0naOE3vCGL940fixMcW2nzNrEAY0hc+N0Xzj2U6hVtr
	DyrMo5fwWXMMwOu+XqM+rUqmGhYgLMMlfDq2BEatrUu3k7nca9lJ6FRurI8Jqtqg9pwv/aQHc8K
	J98xVFTYJTXUrHHCCb0QteKIwMskALSvCn36zd5yBchg0NA+azsJSydwcDUWoaIPslQ==
X-Received: by 2002:a37:a358:: with SMTP id m85mr79061434qke.190.1565006318411;
        Mon, 05 Aug 2019 04:58:38 -0700 (PDT)
X-Received: by 2002:a37:a358:: with SMTP id m85mr79061417qke.190.1565006318011;
        Mon, 05 Aug 2019 04:58:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565006318; cv=none;
        d=google.com; s=arc-20160816;
        b=agQMn5G4Kj9Avbx5pg1Qj3MfxUBCNMrRgVeCdlemfjiARgU4Oc4+24IS3eDba0Pee8
         n3kSsxr0vnFjLZI5s1TAOOBR2xuuMLfEukVybLhCGqg9wwTB71yAriTATysW29Wcm1sy
         wgV8hyU0NrAQzGJN5GlntpeL0qR2i0jks1UQq4uKvV4IBzivjxeBcp9geZWwe3/5qnjO
         4gxpoR2wvogcVgqy3UsridnUbKkbD5rh0fSAYPdvcdf/KqMz7mLhf47DdOVFezdvjtwG
         B8HxyCZZxu3DyBpR80akvVpeUpD4lGLSIyXOymlKSsPM3jZkyAzgBIivp7k1LdNCjgYP
         aL4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=e8LeZYKHIbk2Da0fZqUR7a7Js8ma4FkwyhW8sZVdCZk=;
        b=fCx34kXp1qnNeHvgZVIeeFINAv4m/2v5odbrzxqk1ZX386OfJeUTbDlS/n0LWpDg+Q
         lB9N64zhLlrbWcyiGrlNWx2gmTEgoJi9CJXiH6n2QZr//bd+EHA/d258g0S0cjGvUPL9
         yDxkV6LKBL5zLqkAHC4LhQv8YmbzPIYqMOF+4YS577EBcbFNkQKudNcEnQqXT0/lfPgp
         CtHOFU96tqy9GaXYikrDvZ4e41v8UrK0v4HGWMeqjee34uBHT9dcCUZ/m6UwBEOI5Lmx
         J5RsxO53jVY+P+1SghjS3wpOKx3MNKFIMb1S996qR9lT4rrpEJs4oemO3cibLTc3AG/L
         0DTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hngqHboW;
       spf=pass (google.com: domain of mathstuf@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mathstuf@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s74sor46935885qka.199.2019.08.05.04.58.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 04:58:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of mathstuf@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hngqHboW;
       spf=pass (google.com: domain of mathstuf@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mathstuf@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=e8LeZYKHIbk2Da0fZqUR7a7Js8ma4FkwyhW8sZVdCZk=;
        b=hngqHboWeegeHkoet35hMfGDZ/a/9CNOIPPlA7NKG//W57AWG953gR+21a8vIOnq2N
         O0gY/5V/Q5CZoeXcwKWhnYHZmHPjIPfgIkS1CCntV3/YU320muttIZpPr7T73dzyk1eh
         J8mE0rX4SOvyBpv2kyOrHfn251KwfVS42gfdsBq2ouwztwzMpiiUaEfyj5TeLH2fWGkN
         5HoRjM9ml34Tua73Y6ycsRF6u7bIqTtdkUcIwAlHJz9fMvtiARFg4/EEIVv3xGLVOxGl
         iVEyymREv3wB5kUc6CKPmRZoQQTpjQFt0L224wAgcxG3zATbmMyqyyyJRnhyA7k7657N
         T2EA==
X-Google-Smtp-Source: APXvYqyryDXftcMnqgW+D3kNypxJP/bHopPpzdZ1j1jlioL4L8ry7VpPYRyN6eeewLRhsKtQysUWHw==
X-Received: by 2002:a05:620a:15a5:: with SMTP id f5mr100840063qkk.45.1565006317755;
        Mon, 05 Aug 2019 04:58:37 -0700 (PDT)
Received: from localhost (tripoint.kitware.com. [66.194.253.20])
        by smtp.gmail.com with ESMTPSA id o10sm40861276qti.62.2019.08.05.04.58.37
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 05 Aug 2019 04:58:37 -0700 (PDT)
Date: Mon, 5 Aug 2019 07:58:37 -0400
From: Ben Boeckel <mathstuf@gmail.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 57/59] x86/mktme: Document the MKTME Key Service API
Message-ID: <20190805115837.GB31656@rotor>
Reply-To: mathstuf@gmail.com
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
 <20190731150813.26289-58-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190731150813.26289-58-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 18:08:11 +0300, Kirill A. Shutemov wrote:
> +	key = add_key("mktme", "name", "no-encrypt", strlen(options_CPU),
> +		      KEY_SPEC_THREAD_KEYRING);

Should this be `type=no-encrypt` here? Also, seems like copy/paste from
the `type=cpu` case for the `strlen` call.

--Ben

