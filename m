Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFFCCC282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 11:08:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78650218A6
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 11:08:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="aETz7abn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78650218A6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F17F6B0006; Thu, 11 Apr 2019 07:08:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A00C6B0007; Thu, 11 Apr 2019 07:08:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAA4E6B000E; Thu, 11 Apr 2019 07:08:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id C6DB06B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 07:08:27 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x58so5228943qtc.1
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 04:08:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=BrWL5cUJ7Q9VjCaWG7iC17HiKVbyiOuihuBRu7fgqyc=;
        b=PNd1nR0AEOmEUD1mKyOS93NM+OIB5QYSnXg8j1bB+FLoqO6OLZub8AfzDh1Gl5D2B9
         rGffi2bgXubk5ryhp+LQIqXBktzWWcGVq3HO0CswrmbboQnhkEioYfoveISNlRn/8gq2
         LzXZKcwB+n1y3klpO2rnhkAJHBSJWfZTJZMxlyZVvTNVCpf6MmxenDnUEiwP3XHO3xBC
         EN105A7xSe7+zY3w6zinzWmp0ZFh1oHXnOYrEpRMuBfYikWo5i4lXiMVhEr+hyQGv0ch
         UpmwZvoBW3xLka4Uf0rWyJw6uV+REm/RU2SH5LNMfS4ZR9waElTqq762FRnG1XQxH2Lt
         YFrA==
X-Gm-Message-State: APjAAAVdo53AdBEJ9/XcjBvHfMPg04VHDTGX3tOX6FEboo7lTUmjQ9B2
	/hW1FlYSFh4a13i0MeIYzGr8zxfw1fm7m77KWkXgv48gDns04FtzYRyZCl68VQoURCjw3BzM358
	WLo7+n1KXB2qpacPudHuUU3vAwKakLi8C4k+xuR3lMVEJSY2DbZIotWMEl6qyPFfIZA==
X-Received: by 2002:a0c:b885:: with SMTP id y5mr40855774qvf.25.1554980907463;
        Thu, 11 Apr 2019 04:08:27 -0700 (PDT)
X-Received: by 2002:a0c:b885:: with SMTP id y5mr40855681qvf.25.1554980906303;
        Thu, 11 Apr 2019 04:08:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554980906; cv=none;
        d=google.com; s=arc-20160816;
        b=wovjUOW6uVwbTDuiHYkfsYYBsnCbK6LgGQcxPsCdjgnzE/5R3NQDtv5gDYRoVsoc/U
         qenUPHan8V7k6LkH9PNRPxwcc6Ytt2aWAqxW26pg1s9eAjoCE1Mwa0i6OlGfOptqFPVt
         zVrKN+KSN/hcDvEhIXtmnoFdFTCQqUV5siMB6PZeZLGLh1UEmwtggpooU/Ze/MlxRrng
         b0hIgANwVEt6bBaMvlUgq86XVVBqzb0VwYke/FEAwlJXwpBl8FjtAAaRG+5aeQZMRNkI
         YmJF9eWyyb4MYM4OyyGp9Xt1tMcxWcs/pjoPZBe2Kw5XgULyP9N+21NfJ9YLRW1YL0qI
         zFvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=BrWL5cUJ7Q9VjCaWG7iC17HiKVbyiOuihuBRu7fgqyc=;
        b=0dxEeVwiKtOsPtwn394GO5KyuD7ibcCr9iefp77NkaBTLm+9ykLiSbmZVpaG2d+chD
         5S52m67f3nDiz79mDbkOC+MN6XjNcQrpPzq5JHklGl7oBvLqxwEqr8Uo2/ZS+vM3njLi
         a+uEMohe8shVgFAAwn/OQicJSgUeuluA/9a+O58+/6YgU7ziqcOydDmqSE3/4NigN+Oi
         orEIgUYnx5ZklKvX4DMor0Jsjua3+B9ifx4pniSxfwQMD5wHezhsCHW+2u8zgprhgWyd
         cZfhqqk7BPN/7CSJUfcY3cv/jxTsI+z516G1aJ8csc5AREFvh2iIYqHpLmY4qf9jCkhE
         kLHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=aETz7abn;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o4sor52761330qtj.18.2019.04.11.04.08.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 04:08:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=aETz7abn;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=BrWL5cUJ7Q9VjCaWG7iC17HiKVbyiOuihuBRu7fgqyc=;
        b=aETz7abniOl4e7+DOb09PavxLRotel7kJCk74Ao7xi6iXh4035rmyXLnjLc1AC7QAO
         qmWcaPbYuO08VIlIweDHCdx2ELh+F+QAL4loRPySdpl+sE+HG2YeAgbXgprtG3jGQ/xA
         Od3nE4KuHXRpy+ZxFDJ+Hu9Vcw7BNN1fodzWKd+1vCLx/KZpyYKvCODFl55ylKIzk3RE
         nmElPELmiCkTB1cfq+2jSIDeJIpgNBy+LB2x030VbZQ9zzN7gniLAY1fVyMvxmEe97sV
         I1vak7UGl6CEfNrUNZE7j0eW8p2ItVHpcY44bnK1P9N+RmCA454t7rpukGpOBYhn7eQV
         QebA==
X-Google-Smtp-Source: APXvYqzJI/Ye781pG1kq/AXJLXP983d6SGgYHt0QuC/1Q91EfvxZngkCINzqhN2vJqknEOb7ng8/Pw==
X-Received: by 2002:aed:3a44:: with SMTP id n62mr42701258qte.147.1554980905245;
        Thu, 11 Apr 2019 04:08:25 -0700 (PDT)
Received: from Qians-MBP.fios-router.home (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id g12sm21105028qkk.85.2019.04.11.04.08.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 04:08:24 -0700 (PDT)
Subject: Re: [PATCH] slab: fix an infinite loop in leaks_show()
To: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com,
 iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 "Tobin C. Harding" <tobin@kernel.org>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Michal Hocko <mhocko@kernel.org>
References: <20190411032635.10325-1-cai@lca.pw>
 <43517646-a808-bccd-a05e-1b583fc411c7@suse.cz>
From: Qian Cai <cai@lca.pw>
Message-ID: <02049855-d37f-965e-12f7-f2549cae73ec@lca.pw>
Date: Thu, 11 Apr 2019 07:08:23 -0400
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <43517646-a808-bccd-a05e-1b583fc411c7@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/11/19 4:20 AM, Vlastimil Babka wrote:
> On 4/11/19 5:26 AM, Qian Cai wrote:
>> "cat /proc/slab_allocators" could hang forever on SMP machines with
>> kmemleak or object debugging enabled due to other CPUs running do_drain()
>> will keep making kmemleak_object or debug_objects_cache dirty and unable
>> to escape the first loop in leaks_show(),
> 
> So what if we don't remove SLAB (yet?) but start removing the debugging
> functionality that has been broken for years and nobody noticed. I think
> Linus already mentioned that we remove at least the
> /proc/slab_allocators file...

In my experience, 2-year isn't that long for debugging features to be silently
broken with SLAB where kmemleak is broken for more than 4-year there. See
92d1d07daad6 ("mm/slab.c: kmemleak no scan alien caches").

