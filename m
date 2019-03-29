Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 625C9C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 17:47:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14A282184D
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 17:47:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="q1iL4joG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14A282184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9C1E6B0010; Fri, 29 Mar 2019 13:47:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B49E36B0269; Fri, 29 Mar 2019 13:47:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5FC76B026A; Fri, 29 Mar 2019 13:47:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 668576B0010
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 13:47:50 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a72so1944950pfj.19
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 10:47:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=KkbObhazcqZn021nZHNNPAhwea543VJsHp1ie7WsQS4=;
        b=lCIih6TtWaTuiGqlRRd8ujeDeijunrC0AFtuIyGMkHXx3hyWJKmXtl3SACfXhVt61o
         crxC/nj0I6Gp49TGvE7mdWkoR+F3RIKH3zY/CQe29QFq00UmpmxmE6LRA9+wRjukdR1a
         RrNGKilpH+Yrg+JfU9BPvvORbwllnzODB47CzPMTsxsscGbkMGCRK1uhCwlIkpqgEkZE
         7IaO9/WphWgsmLX9ersVPv6dhwyr3yDH6xfOlpCk/fthrhq9EAcBl3U7UFuUzJb6hfko
         WbcKO9478tZvKa1199GC1rU9fvDxx7VGRptFYxerrBALOYzNR8ujmimdHgVSU72HPfz1
         zlkg==
X-Gm-Message-State: APjAAAXki4JXQbwyXAar7wWY+qh6pU3Pn0CV9mupfqRSRH8/DKB4+gcd
	lvTXydyUrlmF9w6jRUtnv3tfTsOtCI733E8GWFw5vJv5FH2PkOYJiv0xMwR3US5bUs0bBLIh63e
	oOlAhIAGqBMZDYHP6JZs75jPustD3yJlrk2Dk14wKA67bvGPJgMsc6DjWg5QjHpwNuA==
X-Received: by 2002:a17:902:e091:: with SMTP id cb17mr26594011plb.222.1553881670060;
        Fri, 29 Mar 2019 10:47:50 -0700 (PDT)
X-Received: by 2002:a17:902:e091:: with SMTP id cb17mr26593963plb.222.1553881669189;
        Fri, 29 Mar 2019 10:47:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553881669; cv=none;
        d=google.com; s=arc-20160816;
        b=abfoSUhR9aGk42UvUX4Ub+PYgQRmXz4YHo4AyQYW9uj1n8D/gqfvDYRYTDEoDZRR1M
         +UBbsMcGlZwCGVnJ/fivqmEo43xEUC0SmMjLJVruXgBkoDKUJmmILhzGuHDm12J8Y6Hd
         wo6rJVxxZ+udIueKQuWVwCWFWmDlpi5dM18RW1lVWqA4znViUoFN1xAL/rXMNNlcH08x
         og8DqVbV/NBE+VAxHkilXMrs4oITat7OjsX/FrIcr9jSkCeLRqTMJ9VLBK9oGnk2qASw
         8HPU9wPQp9UCdO443oLvBvYmNn/oJLjarLWSND3KyAK2aWa/yMG3DVuC6w9HMRwZFY2p
         TpCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=KkbObhazcqZn021nZHNNPAhwea543VJsHp1ie7WsQS4=;
        b=UMwb2ZmFwIxEhVciL9dAH4+FPshGyqZCOM4RsljYRdRtoyNYa7LwTM8ofFMBz6zMiW
         6mzFAXmfpMqCseQtBZpQe+7xGCgPOhN4W02FmP19vAJxEQBvYsyYws13exhQMbU7gJW6
         ++8plW4BNRg6NipFWmT0ds8Kn8nQsBydNh7/+a0Jd2rXvY3h7uEFWJmq0sk/dX32z0qk
         GD1mqnMJ0eXEQemjg7hLnuxIEmd6puj2ymLqoNd7rvaBFWKqmuM/HSBpRBW8dtj9FGTl
         I5r+HQPAUsHFreoskajyyuamrcXMBL4VHbd8Q9Gh+ye92B0bXhrWzKYn4A2XiO6gDaX7
         H7dA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=q1iL4joG;
       spf=pass (google.com: domain of 3rfqexackcf0boc9g9ibjjbg9.7jhgdips-hhfq57f.jmb@flex--gthelen.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3RFqeXAcKCF0BOC9G9IBJJBG9.7JHGDIPS-HHFQ57F.JMB@flex--gthelen.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id k5sor2710511pfb.26.2019.03.29.10.47.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Mar 2019 10:47:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3rfqexackcf0boc9g9ibjjbg9.7jhgdips-hhfq57f.jmb@flex--gthelen.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=q1iL4joG;
       spf=pass (google.com: domain of 3rfqexackcf0boc9g9ibjjbg9.7jhgdips-hhfq57f.jmb@flex--gthelen.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3RFqeXAcKCF0BOC9G9IBJJBG9.7JHGDIPS-HHFQ57F.JMB@flex--gthelen.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=KkbObhazcqZn021nZHNNPAhwea543VJsHp1ie7WsQS4=;
        b=q1iL4joGvSC0SWToSbwIk7h6Qw0Wb7TsIpPlSjnGJ5khNWGgoW6HoIP4C4lYwbmThG
         E1aFKEsCc4VKFp2/QV7UANYkePMHJTvOhIpjHSTTOc4wi3+B9lTrqCf+8V1E6ODwIbWT
         ih9i2SwjFA5nj9xkVXZRJ7/2iypFpTJZb+ULj26lcaW/fh25fO2pReE+UhaFQq73PV/E
         zk051W9ZXHLYHg/f818uqCJN/C8ZzYbQ2Y7pVeFXgZyjqSUT9Q8mm8z81JCeH35RqrTI
         p8ybWL2qwqcck/fugZG9mwJPQ+zKo1pR4FNVc1iKkLFp2CPLDruCK3gnUpxTqIMvc5I8
         yoAg==
X-Google-Smtp-Source: APXvYqxXhjZZFeoHf4Hk+3gXZNWGmuUCXzlgNhD2c84zWNsCYlOZQnhIri7FEmZ36ZU3YB0RStIcvl2gjIeB
X-Received: by 2002:a62:3444:: with SMTP id b65mr634398pfa.27.1553881668537;
 Fri, 29 Mar 2019 10:47:48 -0700 (PDT)
Date: Fri, 29 Mar 2019 10:47:46 -0700
In-Reply-To: <20190321164453.46143c8bf2dd8bfd0f91d71c@linux-foundation.org>
Message-Id: <xr93muldwp19.fsf@gthelen.svl.corp.google.com>
Mime-Version: 1.0
References: <20190307165632.35810-1-gthelen@google.com> <20190321164453.46143c8bf2dd8bfd0f91d71c@linux-foundation.org>
Subject: Re: [PATCH] writeback: sum memcg dirty counters as needed
From: Greg Thelen <gthelen@google.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu,  7 Mar 2019 08:56:32 -0800 Greg Thelen <gthelen@google.com> wrote:
>
>> Since commit a983b5ebee57 ("mm: memcontrol: fix excessive complexity in
>> memory.stat reporting") memcg dirty and writeback counters are managed
>> as:
>> 1) per-memcg per-cpu values in range of [-32..32]
>> 2) per-memcg atomic counter
>> When a per-cpu counter cannot fit in [-32..32] it's flushed to the
>> atomic.  Stat readers only check the atomic.
>> Thus readers such as balance_dirty_pages() may see a nontrivial error
>> margin: 32 pages per cpu.
>> Assuming 100 cpus:
>>    4k x86 page_size:  13 MiB error per memcg
>>   64k ppc page_size: 200 MiB error per memcg
>> Considering that dirty+writeback are used together for some decisions
>> the errors double.
>> 
>> This inaccuracy can lead to undeserved oom kills.  One nasty case is
>> when all per-cpu counters hold positive values offsetting an atomic
>> negative value (i.e. per_cpu[*]=32, atomic=n_cpu*-32).
>> balance_dirty_pages() only consults the atomic and does not consider
>> throttling the next n_cpu*32 dirty pages.  If the file_lru is in the
>> 13..200 MiB range then there's absolutely no dirty throttling, which
>> burdens vmscan with only dirty+writeback pages thus resorting to oom
>> kill.
>> 
>> It could be argued that tiny containers are not supported, but it's more
>> subtle.  It's the amount the space available for file lru that matters.
>> If a container has memory.max-200MiB of non reclaimable memory, then it
>> will also suffer such oom kills on a 100 cpu machine.
>> 
>> ...
>> 
>> Make balance_dirty_pages() and wb_over_bg_thresh() work harder to
>> collect exact per memcg counters when a memcg is close to the
>> throttling/writeback threshold.  This avoids the aforementioned oom
>> kills.
>> 
>> This does not affect the overhead of memory.stat, which still reads the
>> single atomic counter.
>> 
>> Why not use percpu_counter?  memcg already handles cpus going offline,
>> so no need for that overhead from percpu_counter.  And the
>> percpu_counter spinlocks are more heavyweight than is required.
>> 
>> It probably also makes sense to include exact dirty and writeback
>> counters in memcg oom reports.  But that is saved for later.
>
> Nice changelog, thanks.
>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>
> Did you consider cc:stable for this?  We may as well - the stablebots
> backport everything which might look slightly like a fix anyway :(

Good idea.  Done in -v2 of the patch.

>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -573,6 +573,22 @@ static inline unsigned long memcg_page_state(struct mem_cgroup *memcg,
>>  	return x;
>>  }
>>  
>> +/* idx can be of type enum memcg_stat_item or node_stat_item */
>> +static inline unsigned long
>> +memcg_exact_page_state(struct mem_cgroup *memcg, int idx)
>> +{
>> +	long x = atomic_long_read(&memcg->stat[idx]);
>> +#ifdef CONFIG_SMP
>> +	int cpu;
>> +
>> +	for_each_online_cpu(cpu)
>> +		x += per_cpu_ptr(memcg->stat_cpu, cpu)->count[idx];
>> +	if (x < 0)
>> +		x = 0;
>> +#endif
>> +	return x;
>> +}
>
> This looks awfully heavyweight for an inline function.  Why not make it
> a regular function and avoid the bloat and i-cache consumption?

Done in -v2.

> Also, did you instead consider making this spill the percpu counters
> into memcg->stat[idx]?  That might be more useful for potential future
> callers.  It would become a little more expensive though.

I looked at that approach, but couldn't convince myself it was safe.  I
kept staring at "Remote [...] Write accesses can cause unique problems
due to the relaxed synchronization requirements for this_cpu
operations." from this_cpu_ops.txt.  So I'd like to delay this possible
optimization for a later patch.

