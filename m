Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17E66C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 23:44:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2FA02190A
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 23:44:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2FA02190A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 149BE6B0003; Thu, 21 Mar 2019 19:44:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FB206B0006; Thu, 21 Mar 2019 19:44:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F02CD6B0007; Thu, 21 Mar 2019 19:44:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B38A06B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 19:44:56 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d15so380200pgt.14
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 16:44:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MKFe7IYKhv6cF4wrd3cbm+MYUR0s/luXiG4eosMDJlw=;
        b=ZAUp+9tqDsu+W+quCT1DQ9YnaV4WafkKWG5+5dVbN/6orPo90n/shmqdVui3UwYvrN
         ZWIlAS+OVvho5TtlT6xVfA3h++/A9H7D8pF4ToSaegAYabkCG/EDOja3Rb2BV9Lth5Xh
         vKGShgWkXqJaVgDF/rtVvnPPwS54ImOQdmIWxrtBLAj/Q0vsNxV2sM3DXKmTVVouOLQo
         bGGh/m2hFmVlGbiAUg/oYwOGSZ16CKmsoonGZxIAHb9i5hmZxOOjFKjn14pQKadsntoz
         p68lX5S9l+AK6M9TulIQeKQ0u50T381L4vbKhqM9JlTrWAXvEiOX7e8WGZAChAApXJpK
         fAvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAU1EYxDVb2EYcMFTiXC1pDtJBZuCF2P3OanLgSN9ccCsZ2QlvR/
	9Vbwn6+eHW44atcTiY8tMKVj7P/8cpDKiHzB6aH7nlQAGoPFmr5cbSlmbv0rfTDz3pjSqqUXiGF
	drXqpZhPfz8M6E+e1XpuFBngCHwInaAdvNCpxiTexekytEno6CMYVPlbvMeO9ouDRQg==
X-Received: by 2002:a17:902:2c01:: with SMTP id m1mr6373076plb.186.1553211896393;
        Thu, 21 Mar 2019 16:44:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzA8ZB7WYDCKkrPafBvv90KHH35migZFuyZv5osQksypKAW5jxGQsUMpP1xNeM704b6fys4
X-Received: by 2002:a17:902:2c01:: with SMTP id m1mr6373012plb.186.1553211895206;
        Thu, 21 Mar 2019 16:44:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553211895; cv=none;
        d=google.com; s=arc-20160816;
        b=QuWV8SKaHsAPtplda3ZcSfjg5EbIHs/6k9Caf9YqqNEk35Wajqm/P0X4flTDkp1LFW
         pHA1jBFRuPfpVxBAHLsXCKqHEaYyaQ2oImmr+wXO+4FAiHsZ0uBhbUpLGtfheHsfNHS9
         3Kds7uE14Fg5Rnxu7K57htTXB1QRkeetZP5l5hR99QZ+CABj8+4WVpkR2Zg3QiIKMfEp
         Adi5h6CcA5yN4+urevCGA7fK6T4PbKtFzPuQqAOZgr2YrkUJN3Nhkf+9TUCH+qUfGzS/
         GXg4+qxdTLxi1yUCv3ZWGKnabTJ6c7tjr5qmN31TmP4UwmhvK3YR5uYfWSE02KbOJWPC
         0z2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=MKFe7IYKhv6cF4wrd3cbm+MYUR0s/luXiG4eosMDJlw=;
        b=iazLdoWGYJDnq3B+1U945nEHvbFvT2oUrdsjnUxlgA8Jz00Nd9NPV9CcnIbgC4cCKP
         +gTFqiyKnnabkfv7nEJZHNvP8Jrl8Dd8Pb+TA7+h6y3q2WXAOUQlBnk2Q5E1I5Fao3WA
         D1JXFTF31Q4neuuVXDIOQZdz2SGrA7XWg00F7RaoI2g73hFtpkA/TNRbdoO5wLt9HJxy
         dpjlZEwh27tpzPiq4QmDvjTxmOiOYlKkK/PZ70UFc50O60WABK/IsXzV45EMbLcftP7J
         eIveZqNHeDsckS25B/grpnOkaRV4zp6xqQxqE+nqH8VAD+BM7PqwvxpXzYIQto6FSe8N
         lApA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y24si2874062pfm.127.2019.03.21.16.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 16:44:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 529FCE7A;
	Thu, 21 Mar 2019 23:44:54 +0000 (UTC)
Date: Thu, 21 Mar 2019 16:44:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] writeback: sum memcg dirty counters as needed
Message-Id: <20190321164453.46143c8bf2dd8bfd0f91d71c@linux-foundation.org>
In-Reply-To: <20190307165632.35810-1-gthelen@google.com>
References: <20190307165632.35810-1-gthelen@google.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu,  7 Mar 2019 08:56:32 -0800 Greg Thelen <gthelen@google.com> wrote:

> Since commit a983b5ebee57 ("mm: memcontrol: fix excessive complexity in
> memory.stat reporting") memcg dirty and writeback counters are managed
> as:
> 1) per-memcg per-cpu values in range of [-32..32]
> 2) per-memcg atomic counter
> When a per-cpu counter cannot fit in [-32..32] it's flushed to the
> atomic.  Stat readers only check the atomic.
> Thus readers such as balance_dirty_pages() may see a nontrivial error
> margin: 32 pages per cpu.
> Assuming 100 cpus:
>    4k x86 page_size:  13 MiB error per memcg
>   64k ppc page_size: 200 MiB error per memcg
> Considering that dirty+writeback are used together for some decisions
> the errors double.
> 
> This inaccuracy can lead to undeserved oom kills.  One nasty case is
> when all per-cpu counters hold positive values offsetting an atomic
> negative value (i.e. per_cpu[*]=32, atomic=n_cpu*-32).
> balance_dirty_pages() only consults the atomic and does not consider
> throttling the next n_cpu*32 dirty pages.  If the file_lru is in the
> 13..200 MiB range then there's absolutely no dirty throttling, which
> burdens vmscan with only dirty+writeback pages thus resorting to oom
> kill.
> 
> It could be argued that tiny containers are not supported, but it's more
> subtle.  It's the amount the space available for file lru that matters.
> If a container has memory.max-200MiB of non reclaimable memory, then it
> will also suffer such oom kills on a 100 cpu machine.
> 
> ...
> 
> Make balance_dirty_pages() and wb_over_bg_thresh() work harder to
> collect exact per memcg counters when a memcg is close to the
> throttling/writeback threshold.  This avoids the aforementioned oom
> kills.
> 
> This does not affect the overhead of memory.stat, which still reads the
> single atomic counter.
> 
> Why not use percpu_counter?  memcg already handles cpus going offline,
> so no need for that overhead from percpu_counter.  And the
> percpu_counter spinlocks are more heavyweight than is required.
> 
> It probably also makes sense to include exact dirty and writeback
> counters in memcg oom reports.  But that is saved for later.

Nice changelog, thanks.

> Signed-off-by: Greg Thelen <gthelen@google.com>

Did you consider cc:stable for this?  We may as well - the stablebots
backport everything which might look slightly like a fix anyway :(

> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -573,6 +573,22 @@ static inline unsigned long memcg_page_state(struct mem_cgroup *memcg,
>  	return x;
>  }
>  
> +/* idx can be of type enum memcg_stat_item or node_stat_item */
> +static inline unsigned long
> +memcg_exact_page_state(struct mem_cgroup *memcg, int idx)
> +{
> +	long x = atomic_long_read(&memcg->stat[idx]);
> +#ifdef CONFIG_SMP
> +	int cpu;
> +
> +	for_each_online_cpu(cpu)
> +		x += per_cpu_ptr(memcg->stat_cpu, cpu)->count[idx];
> +	if (x < 0)
> +		x = 0;
> +#endif
> +	return x;
> +}

This looks awfully heavyweight for an inline function.  Why not make it
a regular function and avoid the bloat and i-cache consumption?

Also, did you instead consider making this spill the percpu counters
into memcg->stat[idx]?  That might be more useful for potential future
callers.  It would become a little more expensive though.

