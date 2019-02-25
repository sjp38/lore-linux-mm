Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66F11C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 14:55:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06E602146F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 14:55:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kiMnI9cn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06E602146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 558F38E000D; Mon, 25 Feb 2019 09:55:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 508AA8E000B; Mon, 25 Feb 2019 09:55:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AB3D8E000D; Mon, 25 Feb 2019 09:55:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id D971E8E000B
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 09:55:07 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id v8so1492323wmj.1
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 06:55:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:cc:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=FnueZ7IgA8rCLeU7Gwwu1v68InYcHlydtHfzBGaNhqg=;
        b=IwU7XWU3B7clpqS9w6Du8bZLPd1U685FXDVdZ9FK2o18YHpcsNBieAXLsBtwEZN49/
         80zW/1DQAQAa4krohdMvAvSZDFiTZXeyuswuup7u6vo7g1Gpz0wBGU5SkI/zSsH9ZlaA
         d/1pbT9fCPHmik9x8u29YjG+Smk+ul8V8d6AfvluuZxNZt1Soz5Oedt6Cw2eoKa7/ZVP
         lBVAcsNx/MbqBqQRVC1ecnBE/nf+5L/rKazNtoT53qwqrWZAdaEYD0c/sx3q4sGmwO4N
         ghQjh5wEWEyo5Qbv73Vg0f0sVTEdrAukyppuTrTb7SNkorvVVknfVVG+WbVrUoZ/RIEV
         B7rQ==
X-Gm-Message-State: AHQUAuZ1PdyD1dPQl7kTIccmts7e9I6mUx5ILis/aSBQVLWR+njzJZYq
	Nz47RVaMr5h43B2BA4Q2Y/IoTuLZxdR5000BG8+uZABP8jaTrGYY2MCpbqbBRtrvXUA90QE/K4Y
	P25tp2b6+g5C4t1mjqM4xqWmkg8L85yAHzRw7GRIyl+PHd6lgrAkmqVRlXliS4XeUZRoQilI45H
	NO+CDwpcc/RG5GK4mtn1iXzW/cCkHAFPcYYq1xc29iIbtkrwiE4IKe/rVhYCkpPZyQDnVhgP7fb
	cE+r0+lRxjuQ1Bnu6AGd/E+WQoHuw51qnKOlOA+x66KlBDhO8tqSzbSLHc70VIr6wz4ObZZTpEs
	lc8NXH9dSU9BAo5LEOl2lHh5nTqYUeT/kKKZQsDLSthI+eIoYc/KzpHSJYbZHfeYE7tGrhqLv9U
	D
X-Received: by 2002:a1c:d183:: with SMTP id i125mr10446912wmg.30.1551106507315;
        Mon, 25 Feb 2019 06:55:07 -0800 (PST)
X-Received: by 2002:a1c:d183:: with SMTP id i125mr10446863wmg.30.1551106506204;
        Mon, 25 Feb 2019 06:55:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551106506; cv=none;
        d=google.com; s=arc-20160816;
        b=Dy5i2WonGQVXgY4oyZ1rJ46vR2T+NHGEwEmp7qevAMT4jP5vNr0LXbnBuVI1jJrdG3
         R9cn7Uk708vDRvuyXxa+OH7BRFlFP6OWZbbo2iVdfk4IR+CWYR0VwMR/orUr1doGRVOS
         DC2Pn1mL+NWizIpLm+VUg6ohThzGh/m/Ikv0yzz/H3M89/vqKO+M//FHWBnhW8ewNlTR
         QMhSLfMMYauRnGsOoUuIZmeuPfPP28Yku5VneBG4fqLOoNEQ1zILTxgXEwCb/KivygFI
         RKxlAcYO0w528T0iObBe5zMMw7T4FC0Mex3wbuRCHJObRQjgureu2S2RJsBqqrGfi8/q
         o+dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject:cc
         :dkim-signature;
        bh=FnueZ7IgA8rCLeU7Gwwu1v68InYcHlydtHfzBGaNhqg=;
        b=D36UnI5aA7Bem8SwsgRDXrC9Pgb9tTE4qRAsroiBCmcr1vCeHMpypRynk7Ht8sUEtw
         +aN+bxvD9ENuXVu2+HDoBPNzRefexR7su06LB+587NpzfL4pdi51AIGmlz1gpInEVJ/B
         VOaBvIHyP7r3ZrJR+P2i9uQYU1OzdCisjZ6V6RRVqvlTjeMa9QHMxE23RZwR72hUiNFb
         I/K2nbVJ9SUTuxo8K8U0QOU2JU4Yf4c4/twbj9gMXZtRDEnfMTsT7PUaxV1xflh832vy
         pbnR6pSfSNnnHJSz/QWUBQclALO2WcCm1X7/a/95mX5mB1xxO7vMCPAy/he6NHyuMD33
         PIUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kiMnI9cn;
       spf=pass (google.com: domain of mtk.manpages@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mtk.manpages@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor6291617wrj.29.2019.02.25.06.55.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 06:55:06 -0800 (PST)
Received-SPF: pass (google.com: domain of mtk.manpages@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kiMnI9cn;
       spf=pass (google.com: domain of mtk.manpages@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mtk.manpages@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=cc:subject:to:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=FnueZ7IgA8rCLeU7Gwwu1v68InYcHlydtHfzBGaNhqg=;
        b=kiMnI9cnaFC+hPmjq5tlaHrWWeVu0An8EuJG3iO5RC3aOLJQcE22McBXepYR1KFlrX
         6FOpAh7X3wmrN/cwFhDZQQ3inp1WUMlfd91fTdoHet4VXKjt3zRswPbcvxdwB4VP9gPz
         aSFDv2zemKltI8/JIHnWqxkK5Q0e3NyRAfERuoc3gGxRwjiVjpAVG5FP8kP6I7OBpEtW
         FGuo06wjBQXuZppltnY1ysSh/aDxqrbiY9kElHt5ImM8LlrbvsA0z7weVCLa9M5izYId
         xuaOVyynNTRaGAFSzOvri3pyyhnROsW9lxcKGPFmMclAhhxqtcrkEcus3Vab4aravkhc
         W/Qg==
X-Google-Smtp-Source: AHgI3IZVbhN223HxIrmHpDYhC1vNbII4YQzzRx7nERZ/9nQW80Z5Szvsa9KpxSDk/BK6NkQEI3BAUQ==
X-Received: by 2002:a05:6000:10ce:: with SMTP id b14mr13691963wrx.221.1551106505650;
        Mon, 25 Feb 2019 06:55:05 -0800 (PST)
Received: from [10.0.21.20] ([95.157.63.22])
        by smtp.gmail.com with ESMTPSA id e7sm11403783wrw.35.2019.02.25.06.55.04
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 06:55:04 -0800 (PST)
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-mm@kvack.org,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arch@vger.kernel.org, Benjamin Herrenschmidt
 <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>,
 Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org,
 linux-api@vger.kernel.org
Subject: Re: [PATCH] mmap.2: describe the 5level paging hack
To: Jann Horn <jannh@google.com>
References: <20190211163653.97742-1-jannh@google.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <f89de711-d73b-96be-75b6-0e9054022708@gmail.com>
Date: Mon, 25 Feb 2019 15:55:04 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190211163653.97742-1-jannh@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/11/19 5:36 PM, Jann Horn wrote:
> The manpage is missing information about the compatibility hack for
> 5-level paging that went in in 4.14, around commit ee00f4a32a76 ("x86/mm:
> Allow userspace have mappings above 47-bit"). Add some information about
> that.
> 
> While I don't think any hardware supporting this is shipping yet (?), I
> think it's useful to try to write a manpage for this API, partly to
> figure out how usable that API actually is, and partly because when this
> hardware does ship, it'd be nice if distro manpages had information about
> how to use it.
> 
> Signed-off-by: Jann Horn <jannh@google.com>
> ---
> This patch goes on top of the patch "[PATCH] mmap.2: fix description of
> treatment of the hint" that I just sent, but I'm not sending them in a
> series because I want the first one to go in, and I think this one might
> be a bit more controversial.
> 
> It would be nice if the architecture maintainers and mm folks could have
> a look at this and check that what I wrote is right - I only looked at
> the source for this, I haven't tried it.
> 
>  man2/mmap.2 | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
> 
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index 8556bbfeb..977782fa8 100644
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -67,6 +67,8 @@ is NULL,
>  then the kernel chooses the (page-aligned) address
>  at which to create the mapping;
>  this is the most portable method of creating a new mapping.
> +On Linux, in this case, the kernel may limit the maximum address that can be
> +used for allocations to a legacy limit for compatibility reasons.
>  If
>  .I addr
>  is not NULL,
> @@ -77,6 +79,19 @@ or equal to the value specified by
>  and attempt to create the mapping there.
>  If another mapping already exists there, the kernel picks a new
>  address, independent of the hint.
> +However, if a hint above the architecture's legacy address limit is provided
> +(on x86-64: above 0x7ffffffff000, on arm64: above 0x1000000000000, on ppc64 with
> +book3s: above 0x7fffffffffff or 0x3fffffffffff, depending on page size), the
> +kernel is permitted to allocate mappings beyond the architecture's legacy
> +address limit. The availability of such addresses is hardware-dependent.
> +Therefore, if you want to be able to use the full virtual address space of
> +hardware that supports addresses beyond the legacy range, you need to specify an
> +address above that limit; however, for security reasons, you should avoid
> +specifying a fixed valid address outside the compatibility range,
> +since that would reduce the value of userspace address space layout
> +randomization. Therefore, it is recommended to specify an address
> +.I beyond
> +the end of the userspace address space.
>  .\" Before Linux 2.6.24, the address was rounded up to the next page
>  .\" boundary; since 2.6.24, it is rounded down!
>  The address of the new mapping is returned as the result of the call.
>

Hi Jann,

A few comments came in on this patch. Is there anything from
those comments that should be rolled into the text?

Thanks,

Michael



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

