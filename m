Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A229C282E1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 19:17:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB7C8217D9
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 19:17:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Cvr3QFQ2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB7C8217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C43B6B0003; Tue, 23 Apr 2019 15:17:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 972266B0005; Tue, 23 Apr 2019 15:17:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 888EA6B0007; Tue, 23 Apr 2019 15:17:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id 608676B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 15:17:48 -0400 (EDT)
Received: by mail-ua1-f69.google.com with SMTP id v5so1935285ual.6
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:17:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0R/r6+Dc1HS6D5GD+LDQaGbyZfhrZKOj7KqVz/9sduY=;
        b=Njgv1YTccveBV+r18QkYi8uCek+Vjslocy+cVaXhMvBCPZn7SW5C+BaqZ9+iNzcte7
         knEz3rowKOCM6C90X7CSl3AcMjLIkDoLreu2TMguqtS4pBlVcANUCP4EMLcVkXeRPXOF
         fVZmqVbIuBhg1k4OyTXkTFzKTuU1btBkkgwZWS8hF8G0+RTyuvWObo4wqf61MBzytD6w
         rjsfgL2tnzwAfMpPUipDoCyJrLK0cdUXcrMwkcbrB8UdStUXXNgeL4Fe29Xo7zAlTDiL
         BfpaOi4oymPmgqXPBQLskFDHCDYM2H6ZaMlI+4ri3fvJLoAimUJsPeUiHFLydr/OCSg3
         4m9w==
X-Gm-Message-State: APjAAAWPyFtfTjYA8wlsJ4N7EHhBpORGH+s0cH+V622elX84XUJIdOiE
	tsz/GKDKE3Fd55Oot+TDZJPyxQSzvkrZLxZTF+mK8gBJWL6/vACCWZZfwWoQikDr8hafDBlHHso
	rnNKOVFWetYnLxMRsFTusuB5xGs44GbgiXpqn4ivu3USbZkxxJ5r9GDqUurAfZ9KMZQ==
X-Received: by 2002:a1f:8b8d:: with SMTP id n135mr14934284vkd.89.1556047068092;
        Tue, 23 Apr 2019 12:17:48 -0700 (PDT)
X-Received: by 2002:a1f:8b8d:: with SMTP id n135mr14934244vkd.89.1556047067526;
        Tue, 23 Apr 2019 12:17:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556047067; cv=none;
        d=google.com; s=arc-20160816;
        b=oMjhMfBUOIsSR6zgFA+0RSTftYmecoKgjVgz4lUGYHmmdmY1+g4fgc+G1HD95u8MwY
         vifU4orbGa/7Hae89gK9fQ98QmWzajTytmLrIzqbm+uaecG6A9I0n8xgw7oMlY8ckkfa
         4kZ7OnIl36ykjNcd7rGFfL4QKv03BypECzZz5tpbgCt40fBshHKXsRZmbhE8Hgu3Zrgc
         Ue4e3WSqLmP0tu1wm1mzQ1a/E7+1cl9zKy74BjwTksL5RN9NTjE5MlmGcIj1YGwAAf6d
         mf04Iho5XSlhb6Eme2T5347H903DwuPalxwEWlFOilGJS7OImc2EEOZTD7Kw3WDKsZkp
         I1yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0R/r6+Dc1HS6D5GD+LDQaGbyZfhrZKOj7KqVz/9sduY=;
        b=isqExmg5SDRldNKFkqCCQTv+VLI03HQo1O15yrHT7wpYGmdob8QVtVyW+kX50i20C8
         NTZibq+Ux4ckxgsu9XUNLltdtlpYGJkUQrx3U1vIIeWQeTfXG+OOQTZHVe3WUBGcS4hg
         Lfu+Mx81wsetQ5jRxzrZfXQBUHf6wBPDgWtLlLhm++lhpwb5Nt1lixvSPw5Lvgx0JEWK
         HZbsag08AUiDNddOXTN5/FRMwSK2c9MZ5DS60cDAD9zI4w6skxtx2ZPrKz0Dozr37JX4
         t4y0nxZZGudkp7/iL2XOhZqBNnVygpvu+ntF+cB+ViqjoaAA5YWQYQIbYC21GVoQOYpi
         nCzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Cvr3QFQ2;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o4sor1756628vko.4.2019.04.23.12.17.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 12:17:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Cvr3QFQ2;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0R/r6+Dc1HS6D5GD+LDQaGbyZfhrZKOj7KqVz/9sduY=;
        b=Cvr3QFQ2YBZeOM6VP8GWbG4gVQuTC9seTDsAXY+zY3+Ia4xqkynjotA2UmquFlIKuC
         EDzL2OvkJTJEKfcYglm52pzlmdUvyolQPJpTy54k7dbJk2TusM9qmXtfPAJa/lN4S93d
         kfLFsFz+oaGMN9tjJDfwR54RvQU0d6O3q681o=
X-Google-Smtp-Source: APXvYqzUGnpQMU5jr8R//hyMfbc0Vf7HlpmDNykDd4xY9d+1JwcK9CX344vII4tCZmnpjD4Df/VU5A==
X-Received: by 2002:a1f:84c2:: with SMTP id g185mr14682914vkd.30.1556047066085;
        Tue, 23 Apr 2019 12:17:46 -0700 (PDT)
Received: from mail-vs1-f54.google.com (mail-vs1-f54.google.com. [209.85.217.54])
        by smtp.gmail.com with ESMTPSA id o3sm2150105vko.50.2019.04.23.12.17.45
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 12:17:45 -0700 (PDT)
Received: by mail-vs1-f54.google.com with SMTP id t23so8945199vso.10
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:17:45 -0700 (PDT)
X-Received: by 2002:a05:6102:417:: with SMTP id d23mr5177794vsq.48.1556047064431;
 Tue, 23 Apr 2019 12:17:44 -0700 (PDT)
MIME-Version: 1.0
References: <20190418154208.131118-1-glider@google.com> <20190418154208.131118-4-glider@google.com>
In-Reply-To: <20190418154208.131118-4-glider@google.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 23 Apr 2019 12:17:33 -0700
X-Gmail-Original-Message-ID: <CAGXu5jKcBU43YGooE0NSk5BF9NhdHu6vuFOr8Zq6Fq-Dk4jNPA@mail.gmail.com>
Message-ID: <CAGXu5jKcBU43YGooE0NSk5BF9NhdHu6vuFOr8Zq6Fq-Dk4jNPA@mail.gmail.com>
Subject: Re: [PATCH 3/3] RFC: net: apply __GFP_NOINIT to AF_UNIX sk_buff allocations
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 8:42 AM Alexander Potapenko <glider@google.com> wrote:
>
> Add sock_alloc_send_pskb_noinit(), which is similar to
> sock_alloc_send_pskb(), but allocates with __GFP_NOINIT.
> This helps reduce the slowdown on hackbench from 9% to 0.1%.

I would include a detailed justification about why this is safe to do.
I imagine (but haven't looked) that the skb is immediately written to
after allocation, so this is basically avoiding a "double init". Is
that correct?

-- 
Kees Cook

