Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08BBDC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:07:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8B38217D9
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:07:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="IJmz77rn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8B38217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BB218E0003; Tue, 12 Feb 2019 11:07:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6696D8E0001; Tue, 12 Feb 2019 11:07:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 540638E0003; Tue, 12 Feb 2019 11:07:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 277F18E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:07:42 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y83so16008204qka.7
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:07:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=AmZLIJO0gfRSAXKTvAHHDhr2asaovb+Mn3AnBaO8fWs=;
        b=YqUu1mbSwfLgkz0XV3uxvzPLGE0qgaSRYYL9LcpmJRGk480xoP/Q2KPcm742kFnZrf
         s/ZLx7jMjWsapIfoftUPwI0swVHNuBHDmj5dQCbsJc03wF4Q7Yg0LvgvKoTSUpKDr77M
         BWgSDDqiA1BEdgoN9vH6g33+gz9mAN3E/k8CRPqXwkSodc/ErJb9uN4VCrbJMBvZ8Xwd
         sRGZtatBDfO+oWPo5tO1MH7TD0a8tvZLdia3LvxqcXnawGFN84s+1Ghfb/D/03wc7vdP
         rPYfrgeQqY64VdDJgOHOyWHtDWxI+3U3zOGHZmbbRZoFjAu0o0Ym+jH/BK8d1mFdPWXf
         JjcA==
X-Gm-Message-State: AHQUAuYSxM2GOK8T6DXRyWoM3tCJ8GCMDln6mb8gsF4pnn0b7iEnOICf
	nISF8HEPCVhPro5vjUGzJN4t9lZI+/mMIhj/KSAYUkQgtwIxk/fEa/ly8YsOvNbc9gvrNwGIFOe
	i/0/kEg6L5OgalWcKG5OLtX1ZNSEMfWFdvD7N1/Ih1c+m9v+N+EyP96sbcVdEqxPtGjiO8PIscd
	FqACAFn+4Aj4euciVtHN386Jvrl3eYb1viHCeaaK5hO8ukDri3s0SKX9/O+5PxzPdlUyu4Jonem
	z+wDUvERnp73vMnIHaelGwu0PyyFFyJ3fO3FwgG+aSHPPRQjwgCw4T8OgEZRGmXfIkHMSIdz8KQ
	DD97VHXgFra88jNdgdztWOg5sjFyFr8jM6l1FdWhgk2C9FaChJH3WQWLxYAN0kN4E80Ie+HN6na
	4
X-Received: by 2002:a0c:b39e:: with SMTP id t30mr3200806qve.206.1549987661923;
        Tue, 12 Feb 2019 08:07:41 -0800 (PST)
X-Received: by 2002:a0c:b39e:: with SMTP id t30mr3200714qve.206.1549987661021;
        Tue, 12 Feb 2019 08:07:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549987661; cv=none;
        d=google.com; s=arc-20160816;
        b=EyhNbZCy0ZJV3Qry8GaBRfTrANRupKxX2ctxBK5C99SaKNmcXazPcwhICjJlx23Der
         UnnzDhsfKK4qDtkhstltERLkrtiqefbii5+hqYkHjHpmyrx0mb7A4PA4RuzSuP9hBWl/
         z3QEx0r0oOzc7j/KaX6dN/RCVNfxbIc+Ou0WoznLZFNg2e2sOGKyBC8sSbVCwJWomDDA
         9XJWUceBu8RevVKqtfRwYg66TzIpXCfbikvymUi+k/Fhge1Lw9FphqBVzpxthkgJ4mZ9
         /SIFmHFON4vQvGAnboixlMdjmym/vbcNKe8dLqLDadnH2MxxOwDmNBR7h4tHdq06hdqx
         XS6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=AmZLIJO0gfRSAXKTvAHHDhr2asaovb+Mn3AnBaO8fWs=;
        b=sAobE6rMswu6bp66PO3+G27ou2Gmif9aDqpA78jC8aqKXz+ZYiMFAxs1yZRaqFOEfM
         Lf3DE3Ye4dt50fAr+/QqwepH0Bb8U63Bn3BKtksLjNxb3aRe8RmViOW77iMqkKPoM8Rr
         5MUQedPgg85rsjauF2/4/xzSBFz04nyM3t8sHhusUpQ6e/ExUOfViXfI25us6S3ZJzGL
         /Dw9wQKAG7g/cwO3b8PNBI5EQxaEcX+rbLHwDxhhf7UFWUqOGpJwoqfxojg4peU5V+Vt
         QnycFiLG1a//MlluEV9cnKOrHx1Z7x0RDpRe2fGiB5/HkzikNHQoBbQYiSNPOADOshpa
         VBSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=IJmz77rn;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y186sor7474651qkd.21.2019.02.12.08.07.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 08:07:40 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=IJmz77rn;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=AmZLIJO0gfRSAXKTvAHHDhr2asaovb+Mn3AnBaO8fWs=;
        b=IJmz77rnrC8aJW1GrGatM3SA8D/tKAe8meBIuPnbPzQ6ZJ5P9o7NCZ3r4N13peq6o8
         +/gKU+1WITFhUHRlvL1LzPFEO4z3NJnlj2JhQ1D4bLltpp91uiFMoeRIzmAzKTr8+9nC
         GP5JoJ3wzcj8b2+8Z7W61BokztvK2VWhzw8EYh9O0B7lEh132Yj4nrMdNyrTbjhszMAI
         S12t1gcmQs9aBfqon559lbESBEz+j6gqk8pkuQzcFuihRWD3B340l8A4eUj7h4OD6Yag
         0y74V1+yLA9xBNskGYP6FuOA222FS3JCSjx+cyV6vI8iWm3FlYBI2icCDDLfxS7qjNyw
         afVQ==
X-Google-Smtp-Source: AHgI3Ia+DhAJkD6C0s1c/mrgU8uSC41QzR5n3/jMZ+a7rJV2bORVchdq16empf7IT7JXeM8ZkVFEVA==
X-Received: by 2002:a37:a114:: with SMTP id k20mr2990613qke.274.1549987660729;
        Tue, 12 Feb 2019 08:07:40 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id s128sm13293494qkh.59.2019.02.12.08.07.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 08:07:40 -0800 (PST)
Subject: Re: [PATCH 5/5] kasan, slub: fix conflicts with
 CONFIG_SLAB_FREELIST_HARDENED
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 kasan-dev <kasan-dev@googlegroups.com>,
 Linux Memory Management List <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Vincenzo Frascino <vincenzo.frascino@arm.com>,
 Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>
References: <cover.1549921721.git.andreyknvl@google.com>
 <3df171559c52201376f246bf7ce3184fe21c1dc7.1549921721.git.andreyknvl@google.com>
 <4bc08cee-cb49-885d-ef8a-84b188d3b5b3@lca.pw>
 <CAAeHK+zv5=oHJQg-bx7-tiD9197J7wdMeeRSgaxAfJjXEs3EyA@mail.gmail.com>
 <c92d6890-a718-a968-9937-13bdfeda773c@lca.pw>
 <CAAeHK+xDYvjMxrkczTQaDbMSu5u3GsxW_mFi1=9OAjCi2Q-6iQ@mail.gmail.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <a9d73c21-744c-84f2-78db-a32773b83ddc@lca.pw>
Date: Tue, 12 Feb 2019 11:07:38 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <CAAeHK+xDYvjMxrkczTQaDbMSu5u3GsxW_mFi1=9OAjCi2Q-6iQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/12/19 9:42 AM, Andrey Konovalov wrote:
> On Tue, Feb 12, 2019 at 2:43 PM Qian Cai <cai@lca.pw> wrote:
>>
>>
>>
>> On 2/12/19 8:26 AM, Andrey Konovalov wrote:
>>> Hm, did you apply all 6 patches (the one that you sent and these five)
>> Yes.
> 
> I'm failing to reproduce this in QEMU. You're still using the same
> config, right? Could you share whole dmesg until the first BUG?
> 

Yes, same config and,

https://git.sr.ht/~cai/linux-debug/tree/master/dmesg

