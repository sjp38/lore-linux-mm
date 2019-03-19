Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E516C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 18:32:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D02B62082F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 18:32:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D02B62082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B94F6B0005; Tue, 19 Mar 2019 14:32:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 768B66B0006; Tue, 19 Mar 2019 14:32:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 631106B0007; Tue, 19 Mar 2019 14:32:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21B5C6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 14:32:16 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 73so23068055pga.18
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 11:32:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2XGLLkxwE3qQ26cujfwCvyOVvmwUuuoqk/lAaFyDmeI=;
        b=FMIqdyMMQXzFbM9rDmqK5T59Tj2i7G3BgFe+tziUMTKKtYXfiu+U+CNWzGhIBCmvtQ
         BnsuNRPwI77HrytYwcF2Ld61FSBsK24RDOhZzsw9juisq6cpEwM0jsV8qHp0thoATmLo
         l+QCPZ2HLndSL7/jz5thrt5SWl1hdknXvhQkDcSC5vhQOc292yIAwDknhscv8Jx/LyIM
         q0wd6YwDWn/c6ioJG8SLt5CMxMSBsjj5yzBHd0rhQWBX06iYbAeihWCVeUhFeJJu2o7C
         ds/bN4uHLT0sLiUHlCTC/bI1wZ2EONeomF212EkxVRQQdGZttIJejOpp1UaqkuBxTim3
         CaCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVmH8gCweSAfEEkPB53DGGjL9ZncL19fzJdwDHoFgRI6y7x7uFB
	xwd7dXfAfWcZ1CQMogs+l+TEbVR2Bi7NeX2gIJGpGr78Kkut8JInvhRhC5VZxPV0Bg7XvPl2nRA
	9x0kIGo3bXd7lgoKAyxXh2539ZhB2kJEYYE3LQJWLXQqKXYjONsCJ9MmoaOoGPKvABg==
X-Received: by 2002:a62:449b:: with SMTP id m27mr3344699pfi.79.1553020335720;
        Tue, 19 Mar 2019 11:32:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOLjcL7fkw8ShDJdhNo1A9OGx/4RMEg2sLDeFirKfLWRgAabbwNLQq0LdRiibbElyayfSO
X-Received: by 2002:a62:449b:: with SMTP id m27mr3344639pfi.79.1553020334909;
        Tue, 19 Mar 2019 11:32:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553020334; cv=none;
        d=google.com; s=arc-20160816;
        b=BNeijKtL/KoVmPGXRquRxBV5cGZby/ji2nVsLQ2/+BMOIW0F6IYrrdOEvWLfqPJvCU
         wGKAVLq86orydGvIhu77huYzzMmfpCGq9dGKybYKFnk8D6WTeNOjrGMGieczPjdOEdPu
         887vJ96mh+duik+S0GL3CWEoPLP1jkPs1wEzDaeCEWUhLbWRjqo35eUv4R7zSgn75C+/
         uZjjm6ne9cv7kqWT+kxJxC7bVX0GlTi+l5sTy5C7QlukbrcT0R8/6XeXbEIsygAkHI6d
         13mE8gdbltUAE0ld30ZNvyhiuv7NmfgHZ5S6/uVj6mas4SR79waDYlpfEcr8wZstDWXu
         +P/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=2XGLLkxwE3qQ26cujfwCvyOVvmwUuuoqk/lAaFyDmeI=;
        b=eAz9iZ86eAEO+iLfZgOEWdI/HtsWWbv2Jhx43ER4ce7J76rLc80/05HpGNKQYvIGUR
         1Ko4hdEYJnLeFlQDdnCpc2Z1bJ3OQE6Xz0fg/n9lsaLVb2WPGewMAvnHbWuxzJjTuDKk
         CnMnpLzi1b2xTPRFuOyzD8Whc3/vYmOrcApstsi8uamw77NO1j23hZlifXu8hpASC6XJ
         +PUsTS13WVzIa3yxSa8B58V2t1KzfWL+odueiJ0mIQsR6kXLWQERantTuqGb9oU9oR64
         +qmrbW59AigzJwB8bcIr+xY5RqL6hNw9CUnCbnh3ZGWU+tAorOOGlYGcgBBEdOTDLbE4
         cJHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x9si12405641pll.228.2019.03.19.11.32.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 11:32:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 32ECF3BCF;
	Tue, 19 Mar 2019 18:32:13 +0000 (UTC)
Date: Tue, 19 Mar 2019 11:32:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy
 <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, Kate Stewart
 <kstewart@linuxfoundation.org>, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@kernel.org>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan
 <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, Eric
 Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>,
 Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann
 <daniel@iogearbox.net>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar
 <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho
 de Melo <acme@kernel.org>, linux-arm-kernel@lists.infradead.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org,
 netdev@vger.kernel.org, bpf@vger.kernel.org,
 linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, Dmitry
 Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy
 Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana
 Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley
 <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Chintan Pandya <cpandya@codeaurora.org>, Luc Van Oostenryck
 <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, Kevin
 Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v12 00/13] arm64: untag user pointers passed to the
 kernel
Message-Id: <20190319113212.ca1d56301112454dfb5a39ba@linux-foundation.org>
In-Reply-To: <cover.1552929301.git.andreyknvl@google.com>
References: <cover.1552929301.git.andreyknvl@google.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 18 Mar 2019 18:17:32 +0100 Andrey Konovalov <andreyknvl@google.com> wrote:

> === Notes
> 
> This patchset is meant to be merged together with "arm64 relaxed ABI" [3].

What does this mean, precisely?  That neither series is useful without
the other?  That either patchset will break things without the other?

Only a small fraction of these patches carry evidence of having been
reviewed.  Fixable?

Which maintainer tree would be appropriate for carrying these patches?


