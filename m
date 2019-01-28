Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32328C282CF
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 19:00:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C75AA21741
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 19:00:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="kfKH+nma"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C75AA21741
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 100E08E0002; Mon, 28 Jan 2019 14:00:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 088E38E0001; Mon, 28 Jan 2019 14:00:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE1C38E0002; Mon, 28 Jan 2019 14:00:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE39F8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 14:00:32 -0500 (EST)
Received: by mail-vk1-f199.google.com with SMTP id s196so4683829vke.7
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:00:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HW28ls7Wx+igmjl+yu70fqcBEBBFWWC4XR6jh21UZYg=;
        b=fzrzCNDEBmPLGrkaQj2od5ewRyXK2AV9ViI8lE42WtVKEPs7qJvXXl3eEtgkpVKjGF
         N3yqOoPqM6umIy0CjjKmxbPA0yqEdBZ44OjJHDcWNpCFl/kvP9B3rrUw8uIuv46aHVSr
         z03oqPlYwG+Wx5WFxHHf5KKkLne35h4NFU5LZ0kpnVnPvHhIY3owWltKtWzusycX8NL/
         WVXVTRavjCtcG1LtDWeqUQQrx+QH3xU+awyk/op4pY2XRM/cKYMhsrYgnS4aEsp/8K7k
         M4zZOJbKpUAjxkI+UlkXwgi97ayVGKV6Mi/SoCQpmMnMKM69cLhGJINjCk57Z30LE5q6
         kfkQ==
X-Gm-Message-State: AJcUukdMAAnR0Af/KefO0+XC8YsDrivNlaypOlHTucsNsausnaLLtQ2R
	YWeDcfs7n527gu4/iAKVI0rUrsd4Nq004wljuFV2bjpRSa9lJaKT585UH3bQfFBaywkBbw+Xfu3
	s7lU3gdxTPLJMcaE374vJVKkQ2BF8xTZzxVZG2zXdPVXN/ls87eLqX9IQFBMKCqQb52Fdm9De45
	ZWdAt/QUFqQNRDn+wFpTFTWwxcDr9XavD01OWBxXtXS5TavkfVVMxSK7KNy/3755M32DPH8k6b5
	etV2vNIQipvgCCDwYFzcgGhBPKEKh+6VRNgFhE7hY0+zIc/ZFtpNyWXlGTv+yxY0NKFq1oXH9jY
	Yi76rENUZcQQlZBFk0PQBsx8n0JSC+uQIm8zyHwFm5V7ARtsDRYvhPpwgZdyC/giQ+y05IqLdU7
	+
X-Received: by 2002:ab0:148e:: with SMTP id d14mr9406543uae.23.1548702032347;
        Mon, 28 Jan 2019 11:00:32 -0800 (PST)
X-Received: by 2002:ab0:148e:: with SMTP id d14mr9406510uae.23.1548702031585;
        Mon, 28 Jan 2019 11:00:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548702031; cv=none;
        d=google.com; s=arc-20160816;
        b=eo6E/NQ62NRk6KlRqEEdSCXYrV+KpA4KLjtsl66ofkdq844p+Z3fTVbKoE8IlpoKX9
         yajIkXqdUlgdMrrsdDjq+PcljlIuPlx7SqB6EY6RuW9c9R8WBjroj8DtLcJJ2T3d0ldu
         RFXCUV+l36234ivemfPEn4VBAtHqTuKUznw7l7ocV3CzWTGxqMVUHp4+sVJ7uO47XN/j
         zjzUUGqC+EkRBPvltjsqef5saRgxd1Tb6TdthxFbSLpQayaQ71MU+aBQUipeNv+Zh3hk
         MnXOCMujCU3bJHzwQaBgNPKnsfkd8FU9fy2QQ4+VclMpjxJehRC2sggoTb4Hi9Yy7CpT
         ApcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HW28ls7Wx+igmjl+yu70fqcBEBBFWWC4XR6jh21UZYg=;
        b=YYFuTsEZy9iPIsB/odxfmAeuINTGfXiMVuhe2uleTTQBoC3aOu2NUXuGa+Ofwk+7BE
         ZK8SjAUNtG08HdS7ddGCkAggAKb15FqmNqgZRVBMgS1p3D9g8QRDZtbcBprtcmSmkJYC
         Nsvq4v3Jr4HUXJ4TlotAC8zA7NMHMjqBxBtdbo1w4/ze7VECm9kfKQdkaC0scURMTibh
         v4EBasDNvBmiigHUPwL7pf+CqQGMzmD/VFuBn4yp/VNPR8JWR1+eUNQvI780Lshh4kNT
         tyGg9uM+/DUIFcdOxgrZ9RhyNngMVrOcrkaXwYJMbNIlRLyCgKAku7bkHJ5RBq9Ro9Ng
         tQIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=kfKH+nma;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a23sor19098677vsq.48.2019.01.28.11.00.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 11:00:31 -0800 (PST)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=kfKH+nma;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HW28ls7Wx+igmjl+yu70fqcBEBBFWWC4XR6jh21UZYg=;
        b=kfKH+nmaemVN1YLHaFgCdpR8oIM1Il/wC44Xsc3dCbL7K7GWHY/x23uRnB+zY2JwO9
         0goxzN28D1fXTVU7AgBKBinIv1rd824L7tNtIe/DlAN6O4P8Sil7cwq77F0jP6G83wJ7
         6/t4SE/k8w1Hl1+2IJGM1jRzyCkgua/nCMkPQ=
X-Google-Smtp-Source: ALg8bN6wmKhLKZFaLRxECIE27wJhHgffj42VL4ZsKFBNYOENfnidPMNxDrcIHgRVCliyVHQlYr/wUg==
X-Received: by 2002:a67:8188:: with SMTP id c130mr8349912vsd.43.1548702030888;
        Mon, 28 Jan 2019 11:00:30 -0800 (PST)
Received: from mail-ua1-f51.google.com (mail-ua1-f51.google.com. [209.85.222.51])
        by smtp.gmail.com with ESMTPSA id k200sm74658399vke.9.2019.01.28.11.00.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 11:00:28 -0800 (PST)
Received: by mail-ua1-f51.google.com with SMTP id d19so5989509uaq.11
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:00:26 -0800 (PST)
X-Received: by 2002:ab0:740a:: with SMTP id r10mr9002232uap.14.1548702026118;
 Mon, 28 Jan 2019 11:00:26 -0800 (PST)
MIME-Version: 1.0
References: <20190125173827.2658-1-willy@infradead.org> <20190128102055.5b0790549542891c4dca47a3@linux-foundation.org>
In-Reply-To: <20190128102055.5b0790549542891c4dca47a3@linux-foundation.org>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 29 Jan 2019 08:00:14 +1300
X-Gmail-Original-Message-ID: <CAGXu5jJkf4pKr0WVUcFitZnnUbq3annautZxzYPC0TQaB5HaGA@mail.gmail.com>
Message-ID: <CAGXu5jJkf4pKr0WVUcFitZnnUbq3annautZxzYPC0TQaB5HaGA@mail.gmail.com>
Subject: Re: [PATCH] mm: Prevent mapping slab pages to userspace
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@surriel.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Michael Ellerman <mpe@ellerman.id.au>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 7:21 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Fri, 25 Jan 2019 09:38:27 -0800 Matthew Wilcox <willy@infradead.org> wrote:
>
> > It's never appropriate to map a page allocated by SLAB into userspace.
> > A buggy device driver might try this, or an attacker might be able to
> > find a way to make it happen.
>
> It wouldn't surprise me if someone somewhere is doing this.  Rather
> than mysteriously breaking their code, how about we emit a warning and
> still permit it to proceed, for a while?

It seems like a fatal condition to me? There's nothing to check that
such a page wouldn't get freed by the slab while still mapped to
userspace, right?

But I'll take warning over not checking. :)

-- 
Kees Cook

