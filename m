Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FC1CC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 02:56:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AC1E20842
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 02:56:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AC1E20842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5F648E0004; Mon, 11 Mar 2019 22:56:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0F1F8E0002; Mon, 11 Mar 2019 22:56:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD8DD8E0004; Mon, 11 Mar 2019 22:56:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F10E8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 22:56:32 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id d49so1003436qtd.15
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 19:56:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=bzMUsu5FGRfqkUpBkiKCi1f1o4wZkOeI47MzQSOTMcg=;
        b=nOgG3essQ8Q8txBpzpEszeHU8pIux0DbhqLol3uv3d8TF83G4NQrVMANJK7qd6j9yh
         7yPbuNvUdcv0mn9IgDoY9J84kzcvF8Sj5J00QOum36j3UqjB/JgthF7btD3Sz2CNsvmR
         0aXZWwRJLo62k8b9EiS/SydFm+90jQoAwcM2X0+YgA2cnkqUOXcQjOIfzHvhm36MlWOF
         xegEqAQlp+MRRYUiegv83+gsgnxZfmA4uFWPoYbTY7ftN8P3HvfIwKYjTNncsanVlXrj
         tlKW3JrHekVopRYj3wlP9o0NowBdiGQ58LkxbFtL/zyZl+Yndmb2+oJs1C8ZKi/zPXlb
         dQBw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU3wFQ3p/aVYlPOXgJPBq5q4z3P58ipWx7uTM0JiWCGViSNJEMA
	E3gNWhRQJYvPQJyfMtvCjyf6nLgvz4JUX7b/SR7JWcZXOfbfRoTw8NGRVwAw0nTZSMkRMP8VfMV
	I7RXv4X9juXuPwjgkeUabMaKIv2ArvA12rwBEU4UVa5noPGvUXJRls/5Ye1w3gYAvZg==
X-Received: by 2002:a37:e503:: with SMTP id e3mr25604207qkg.316.1552359392316;
        Mon, 11 Mar 2019 19:56:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGwN4egn4M2FGrsvNEsee6qlB8M9uKfxnFs0EiXDyyAChHIUDt9hU9nn2UomJFlNUeIIb+
X-Received: by 2002:a37:e503:: with SMTP id e3mr25604185qkg.316.1552359391533;
        Mon, 11 Mar 2019 19:56:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552359391; cv=none;
        d=google.com; s=arc-20160816;
        b=QVP6jq5f23jtTpGyTNWy7VnS+YpRnxIqZB3Mip++gHTa5Abvi4i4+6dMmFuaU+Rs7L
         4URgTV7/LAWK/K4HwcHO+rmqfIDpOnIR9vukP9u74phbEHJXRkScWvAx4Z+FLVM7Fm7z
         IqT1G4hB29ZinrRM2f2l0rwUa2wAEBScUQ5zoZ7JdiktgTN8s9ejxrK+3ZNbrN2a7GrK
         V5d7kWigy2SuBYoO1h3kEnWDs5f4LQxOn0emDBgf/ki9CqDr37L9/hat+gtWchXpcggC
         tgMVPkS7sggg8iqENYu80hiuV3RTz//jKv5Z65Tp/QcTf7IRtN6bYbKX7piyxYSMMJFO
         Q50w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=bzMUsu5FGRfqkUpBkiKCi1f1o4wZkOeI47MzQSOTMcg=;
        b=emizsgovVxdq52v8xL8j8mg0b4u2pBWdsF2fSzwJTgl31og15fDkgxCVkhfP80kr8p
         V4z4G0/I7t2lE3aJdgzaDkF+KpiiTaIG6Uc0Xk8Txb2fFG2jc/20AxR3sDCIiPShlvPU
         u+sn19O1wdZHtsHiePDxFDbLxI15v8yCVC8LGpHlssgjJneMEt78bczillkK7CoXU1Zn
         JYF27sFLM7HEa2lPb5dIxz2u0YLcKJNb0FYR/11JuZwwJyE7zVSDgRqAxysJxomN7SiZ
         xaW3dCpOW+4T6SlAGffZGZniuUtENjTmTg+a8pqnPQK1pZZP/CRSdWycNmpxg6Lp3KSN
         3tjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b66si232346qke.128.2019.03.11.19.56.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 19:56:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 928DE88313;
	Tue, 12 Mar 2019 02:56:30 +0000 (UTC)
Received: from [10.72.12.17] (ovpn-12-17.pek2.redhat.com [10.72.12.17])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A380460C4C;
	Tue, 12 Mar 2019 02:56:22 +0000 (UTC)
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
To: Andrea Arcangeli <aarcange@redhat.com>,
 "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, peterx@redhat.com,
 linux-mm@kvack.org, Jerome Glisse <jglisse@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191622.GP23850@redhat.com>
 <e2fad6ed-9257-b53c-394b-bc913fc444c0@redhat.com>
 <20190308194845.GC26923@redhat.com>
 <8b68a2a0-907a-15f5-a07f-fc5b53d7ea19@redhat.com>
 <20190311084525-mutt-send-email-mst@kernel.org>
 <20190311134305.GC23321@redhat.com>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <4979eed5-9e3f-5ee0-f4f4-1a5e2a839b21@redhat.com>
Date: Tue, 12 Mar 2019 10:56:20 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190311134305.GC23321@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Tue, 12 Mar 2019 02:56:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/11 下午9:43, Andrea Arcangeli wrote:
> On Mon, Mar 11, 2019 at 08:48:37AM -0400, Michael S. Tsirkin wrote:
>> Using copyXuser is better I guess.
> It certainly would be faster there, but I don't think it's needed if
> that would be the only use case left that justifies supporting two
> different models. On small 32bit systems with little RAM kmap won't
> perform measurably different on 32bit or 64bit systems. If the 32bit
> host has a lot of ram it all gets slow anyway at accessing RAM above
> the direct mapping, if compared to 64bit host kernels, it's not just
> an issue for vhost + mmu notifier + kmap and the best way to optimize
> things is to run 64bit host kernels.
>
> Like Christoph pointed out, the main use case for retaining the
> copy-user model would be CPUs with virtually indexed not physically
> tagged data caches (they'll still suffer from the spectre-v1 fix,
> although I exclude they have to suffer the SMAP
> slowdown/feature). Those may require some additional flushing than the
> current copy-user model requires.
>
> As a rule of thumb any arch where copy_user_page doesn't define as
> copy_page will require some additional cache flushing after the
> kmap. Supposedly with vmap, the vmap layer should have taken care of
> that (I didn't verify that yet).


vmap_page_range()/free_unmap_vmap_area() will call 
fluch_cache_vmap()/flush_cache_vunmap(). So vmap layer should be ok.

Thanks


>
> There are some accessories like copy_to_user_page()
> copy_from_user_page() that could work and obviously defines to raw
> memcpy on x86 (the main cons is they don't provide word granular
> access) and at least on sparc they're tailored to ptrace assumptions
> so then we'd need to evaluate what happens if this is used outside of
> ptrace context. kmap has been used generally either to access whole
> pages (i.e. copy_user_page), so ptrace may actually be the only use
> case with subpage granularity access.
>
> #define copy_to_user_page(vma, page, vaddr, dst, src, len)		\
> 	do {								\
> 		flush_cache_page(vma, vaddr, page_to_pfn(page));	\
> 		memcpy(dst, src, len);					\
> 		flush_ptrace_access(vma, page, vaddr, src, len, 0);	\
> 	} while (0)
>
> So I wouldn't rule out the need for a dual model, until we solve how
> to run this stable on non-x86 arches with not physically tagged
> caches.
>
> Thanks,
> Andrea

