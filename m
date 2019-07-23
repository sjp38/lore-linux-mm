Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29E67C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 23:14:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B479C2253D
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 23:14:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="H/is+lPc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B479C2253D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1ADA6B0003; Tue, 23 Jul 2019 19:14:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCA786B0005; Tue, 23 Jul 2019 19:14:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE09B8E0002; Tue, 23 Jul 2019 19:14:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1CB6B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 19:14:14 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id y22so22885598plr.20
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 16:14:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KzEPEjlcL6GEOTasJgLRJ8+KfYG37wARexolVdQ94+8=;
        b=FfcvxX3obIorzZGBbpMraZUFbTHjpNpHAGU4q788hz90I+lM8v3K1Hg+iWLKAsYpyP
         MZ5s5xV9zpCKXHoPOP1yi7HFC91Ezrf0Yz4rkd1o6jmfiPjQ2f1FZ6Z8gsrWrm/sFWop
         gMuI6cHbx4QuVQGx37T9mmrE3wndhJMtIZpj7AaVr7BCnPDKpabulx2PPCG9cIXvY1VY
         l3F0gUK6QfTDdg9yXYsdoWhKBy73nW9wbOxotBkXWEjgTv8RpFKrRBiPNwdFJjcA7C/m
         z+k/EzfOPzSOHipxkKZ9asMZAkCLhe+eI9Vo3ZjEaujCFNX7UUTNwE8P1isIPNGYPyIf
         tOzA==
X-Gm-Message-State: APjAAAWIZfgspxzqjVn7UgDdBfYkLYXUxxQoPfyQyv5JoJyUbu7SH9kc
	YWvaGpRBccAGrms/fyaq5lH3TllA2BAX81xsnhBygpyCSQL7xgtvMVyDgdLCSUqVL+u9AKfaxUR
	JdDVrdYfDZ20seJ+f/mkw5s0sBsYRYnIIoR+pqUexkwAl1TbFQRx0xvXw4v572w4n4Q==
X-Received: by 2002:a17:902:5a2:: with SMTP id f31mr81548708plf.72.1563923654219;
        Tue, 23 Jul 2019 16:14:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxd3AjwjSnm3qgLbAB8iJF8zbkrj9ZqvA3Z9yECfuM7obCwQsolnUdkZtl9TjR5KldzfPaL
X-Received: by 2002:a17:902:5a2:: with SMTP id f31mr81548661plf.72.1563923653417;
        Tue, 23 Jul 2019 16:14:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563923653; cv=none;
        d=google.com; s=arc-20160816;
        b=tiGQhFAIxtmPY9ku9fKmwvRKiXsM3VdgLEL9FW0vsiW5hUNT6HGGb1GvlX00zc/vL9
         GOSNei84OpiHQbdRqzOOLyR1bebPh+8ePGcGedqTr60/tU/5YTlafKxuung53mtQx1jw
         9G3UUqFnh4PX2vOqdOu1alPyizy6ayDzoTh01PpTg/gmBfRwzwGxzTBNNh475ibse7ZK
         oK/CmxcOd6DQo9dI9bOX0hZmfwQQmKOfqPraAapeGWzKCvfBIQI4OdW8hANtGzX6rwsb
         Skb4VeWJNqedCN3UoSMNc5F2g07vjyKB0sYDvVNp3LY6Sin+R1a8UELSd24m8UkN9PBN
         JzTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=KzEPEjlcL6GEOTasJgLRJ8+KfYG37wARexolVdQ94+8=;
        b=pV7Jt2D/iSWFcWq4LcQIYPIDgpbermu1sPm7NxKyiAhgQpoyd/wuVYOqGid7xHUmFh
         43CmwqUm/cv7JoKT6y+cSKKFv58SjAFT1DAe2XuUl4rv38oi7HQ7hRDBLCobiGpNnOFc
         D70XRBS0ldJCIy6ZoCuZRaIBwFRqtu+7y90Vq60CT4lOQKvE7SXzv8jgUOekMSbeJwpc
         81x8EOLTUJT9/e1nUcSI+DXRx17wP+/1aw9uVUtMYyFuYc6mplkljwsW8aggAVnX/Z4G
         uhEbqwmJ9v+FLOOHn3cRphtIdvX0oED4sgGFRQuIVTxw6T0GsnK7L1RH1n3xwZAiOJhx
         dr2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="H/is+lPc";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q19si13413434pgg.521.2019.07.23.16.14.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 16:14:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="H/is+lPc";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.64])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CCC282253D;
	Tue, 23 Jul 2019 23:14:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563923653;
	bh=lw124mTrOq6s0ksdXzyc2Oln5pXIDUq4BhFKcu/YBF4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=H/is+lPc7+MKPGbjO35Cz5fZMCCV+SCv/slPD8z/ItwgSn0sCA7qrhYwzbs1cNdgc
	 7u0uumNpvlVdqyqDWXMgpXzMRSQC+J6JKOIuiywlZEaaSNvRn9O9aj31fRJtu5YbNK
	 ReZIdHzhA+xVJxkRJuAJXAXr54GoumPP076glx6Q=
Date: Tue, 23 Jul 2019 16:14:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Roman Gushchin
 <guro@fb.com>, Shakeel Butt <shakeelb@google.com>
Subject: Re: [PATCH] mm, oom: avoid printk() iteration under RCU
Message-Id: <20190723161412.df47e0c9ecd8bc28d3183604@linux-foundation.org>
In-Reply-To: <1563360901-8277-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1563360901-8277-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Jul 2019 19:55:01 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> Currently dump_tasks() might call printk() for many thousands times under
> RCU, which might take many minutes for slow consoles. Therefore, split
> dump_tasks() into three stages; take a snapshot of possible OOM victim
> candidates under RCU, dump the snapshot from reschedulable context, and
> destroy the snapshot.
> 
> In a future patch, the first stage would be moved to select_bad_process()
> and the third stage would be moved to after oom_kill_process(), and will
> simplify refcount handling.

Look straightforward enough.

>
> ...
>
>  static void dump_tasks(struct oom_control *oc)
>  {
> -	pr_info("Tasks state (memory values in pages):\n");
> -	pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
> +	static LIST_HEAD(list);

I don't think this needs to be static?

> +	struct task_struct *p;
> +	struct task_struct *t;
>  
>  	if (is_memcg_oom(oc))
> -		mem_cgroup_scan_tasks(oc->memcg, dump_task, oc);
> +		mem_cgroup_scan_tasks(oc->memcg, add_candidate_task, &list);
>  	else {
> -		struct task_struct *p;
> -
>  		rcu_read_lock();
>  		for_each_process(p)
> -			dump_task(p, oc);
> +			add_candidate_task(p, &list);
>  		rcu_read_unlock();
>  	}
> +	pr_info("Tasks state (memory values in pages):\n");
> +	pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
> +	list_for_each_entry(p, &list, oom_victim_list) {
> +		cond_resched();
> +		/* p may not have freeable memory in nodemask */
> +		if (!is_memcg_oom(oc) && !oom_cpuset_eligible(p, oc))
> +			continue;
> +		/* All of p's threads might have already detached their mm's. */
> +		t = find_lock_task_mm(p);
> +		if (!t)
> +			continue;
> +		pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
> +			t->pid, from_kuid(&init_user_ns, task_uid(t)),
> +			t->tgid, t->mm->total_vm, get_mm_rss(t->mm),
> +			mm_pgtables_bytes(t->mm),
> +			get_mm_counter(t->mm, MM_SWAPENTS),
> +			t->signal->oom_score_adj, t->comm);
> +		task_unlock(t);
> +	}
> +	list_for_each_entry_safe(p, t, &list, oom_victim_list) {
> +		list_del(&p->oom_victim_list);
> +		put_task_struct(p);
> +	}
>  }

