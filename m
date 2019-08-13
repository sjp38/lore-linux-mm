Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2057DC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 13:07:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4926206C2
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 13:07:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AMQCAmjV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4926206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89DE86B0006; Tue, 13 Aug 2019 09:07:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84DB26B0007; Tue, 13 Aug 2019 09:07:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73D3D6B0008; Tue, 13 Aug 2019 09:07:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0064.hostedemail.com [216.40.44.64])
	by kanga.kvack.org (Postfix) with ESMTP id 521EA6B0006
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:07:05 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 0DCDE180AD7C3
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:07:05 +0000 (UTC)
X-FDA: 75817430010.11.cars66_5ae757a782d32
X-HE-Tag: cars66_5ae757a782d32
X-Filterd-Recvd-Size: 4211
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:07:04 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id r4so79433264qkm.13
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 06:07:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=u2xvKIFDx1GL5oTSP01MeCVOPBZI+ggPw3/ysWgy6nQ=;
        b=AMQCAmjVMkny/5BGWEJOty2vX6MCoQOq1G95l9/RhyYwDeuU1PMYleA2bWX5YliVyH
         rOauuQZa/wbMZf2yl6pD0hCEWri5sJtc3UjkvirA0NdQZoRA6c8M94xWGChvU/JmHNqt
         AMVDQAKeV8OOie/K4ms5uDBSsivZB7M+hlK/9skh8vbJJCO6V0a2vgY7cn8oEYUNeubg
         1Lg52jf2CO154nU8/4GHcAoz8DThCz1yU76rM2x+akAQjE8TesDkXLiCRVGfZ4bXEgyW
         kpOXbQ9xTc0dlYdPf2yGSqH43dJ5sNs6pDt3QOF8N/DPjsWSmy+59G0ej6J3mPFa6WAd
         P8vw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:reply-to
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=u2xvKIFDx1GL5oTSP01MeCVOPBZI+ggPw3/ysWgy6nQ=;
        b=sVkHieLgnCJgiR7jqaxINZT8qiyWWPD9JKjgkTyjrm1o0syzfmKs7mGeOy1jmH7KmC
         nZnVFF1LKLg4nUSGXPoHjK1rV3IvvNmDJRoqVoEff2DzcqyARwscqBkvaV/at56Ymgs+
         1iRBntSsDeDOMwnCKehF1+0S6CXRKHWEzsuVBOiTE9ztwSYW1NFDppAk3u3FXulaQDR5
         xBy8iMkVoXG3gSCYu16fsrUlSYUF3KfGxiwVKKCsrU4XLjf6lEapF/VTfXYlk2jhzj41
         pxvkwyJXB+qlx1fGGkxaVslCZLv5gFzRgVj24Q/RX1vOSAxU70T/FW9RDIn+Hoa8M2GM
         SFSg==
X-Gm-Message-State: APjAAAUyQnvzHW6yaJwa/tDiQ8Fv7aezchguF2MBF1tRZlFvgL72dtXK
	K8DIUBc/O9tQvltVXN/tMcU=
X-Google-Smtp-Source: APXvYqwQcmk/rYDeQGfkSovcy7x1HElxEfyMb+XjS4Vy1redRSZJ+8OA4u4px8DqFuh6ELZ0M4OLzg==
X-Received: by 2002:a05:620a:12d2:: with SMTP id e18mr33667320qkl.176.1565701623607;
        Tue, 13 Aug 2019 06:07:03 -0700 (PDT)
Received: from localhost (tripoint.kitware.com. [66.194.253.20])
        by smtp.gmail.com with ESMTPSA id f7sm2448257qtj.16.2019.08.13.06.07.02
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 13 Aug 2019 06:07:03 -0700 (PDT)
Date: Tue, 13 Aug 2019 09:07:02 -0400
From: Ben Boeckel <mathstuf@gmail.com>
To: Alison Schofield <alison.schofield@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 57/59] x86/mktme: Document the MKTME Key Service API
Message-ID: <20190813130702.GC9079@rotor.kitware.com>
Reply-To: mathstuf@gmail.com
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
 <20190731150813.26289-58-kirill.shutemov@linux.intel.com>
 <20190805115837.GB31656@rotor>
 <20190805204453.GB7592@alison-desk.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190805204453.GB7592@alison-desk.jf.intel.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 13:44:53 -0700, Alison Schofield wrote:
> Yes. Fixed up as follows:
> 
> 	Add a "no-encrypt' type key::
> 
>         char \*options_NOENCRYPT = "type=no-encrypt";
> 
>         key = add_key("mktme", "name", options_NOENCRYPT,
>                       strlen(options_NOENCRYPT), KEY_SPEC_THREAD_KEYRING);

Thanks. Looks good to me.

Reviewed-by: Ben Boeckel <mathstuf@gmail.com>

--Ben

