Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD8A0C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 18:15:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A167020882
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 18:15:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A167020882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20C4F8E0002; Mon, 28 Jan 2019 13:15:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BA738E0001; Mon, 28 Jan 2019 13:15:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0AA418E0002; Mon, 28 Jan 2019 13:15:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C09648E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 13:15:17 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id e89so14609821pfb.17
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 10:15:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YLQfkP1Yh3Zq7Vw4IS447I2kGeznx+nwCzDsqeofSZE=;
        b=KEcoP+VVPa1HdUd8fTJvJz1XwbncC6vStgkWKKrEKE1e4mPpkHem/Q+cjRnyDyEs+a
         RTCgJ/i8XA1za7Mf5H+yTqzBco8yKTeYSgJMmlFsKwhu2jAqXaSR4bA94KeEngOrX9SH
         2LSGH5Rt9ltv4PnMAr3tJ3DxF5YVJ+AXzLUd0eNlrt2J16iExE+Yd4ve6kb7oGipsmk3
         FZc4f+CqVVadZw7VAlJupdN0xiwXmfzjngzZzMjrQIOJ3Fjds9uS8KzPZ1VuHzQCnoVe
         XJbA57HXGDGnDhj7OIK/4oWPJYrvSM6m6DkmPCBchPZHH4hgpEQxOSudBPZPFkFEX+iO
         C6jw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUuke6Rl2icY506och3rB1Q+1Osio+fc6T0cBMVe0ifPUVh3J9JCBW
	NUzwDfwbfGhDUQQjJ8vPh1L4l1rYBEihNIstEDZBqNkzPj7f60TeggBqF8tc4JnrrI+fVhn+vA4
	h1JwD3Yc1da1ZmgzLW6QoihkZaHYjyZRDxsMBNkWoXbLDgJmuxH3DkMEVYnLJOjCxuA==
X-Received: by 2002:a63:5455:: with SMTP id e21mr20923111pgm.316.1548699317478;
        Mon, 28 Jan 2019 10:15:17 -0800 (PST)
X-Google-Smtp-Source: ALg8bN75H2sLH+3bwONc8pBjHeubtj7dIGnAyuK9z4zCQLU4GzaBwMNyJbI3kb/rw0jF6/AaXiC6
X-Received: by 2002:a63:5455:: with SMTP id e21mr20923053pgm.316.1548699316624;
        Mon, 28 Jan 2019 10:15:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548699316; cv=none;
        d=google.com; s=arc-20160816;
        b=Ly9Kokk0p15SAlVv7cYcbfj4BItg+5B4Y8rifE2stIhabiQW/oqmZ9qmJJnTde5rt5
         QdxweoX02+qHK1b/j7SqdWJ2Qxyyj0akQ8SMRWiYW+NLxua1C2q5YsA6tKFcYLxkaJOh
         VukozZ11X1A5kLp2Rpjn4WEdakBOp980q+soTu+iLt7NTQdl6d1ap306Peck3QKQFC93
         /ovbUe6Dx7PLqAl/ReI29CsQV94zKFkpbYiuwzlYG/G0Sr4pzqpYPWvdwUMf6m5KHLuz
         VlfUASF2xc7zg9oqqkaEm6Ax+rPgP/OO+tEUVR16PFHgrX/v8SI9cSxOjffhZaF3yZ+a
         eyRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=YLQfkP1Yh3Zq7Vw4IS447I2kGeznx+nwCzDsqeofSZE=;
        b=xpj8HYQnjldmkeUw/3jqjN7aRZQdiJcFHRpnSDQQmLQPD3/Zo/6NnbS88KhFWq6Bxr
         EHAkRvw/1PTvA99AlUnppUsh/ToVNcDmhevao4ut2JMh/AGsUSTtrwndpRPe8XDqQ05v
         Hnv0nfSug1/TNgBSo991zyiZsxHo9MmYXW/+aptc4M+inLwDC5uaK9PpGNkG4zso3Sr1
         PBvatFiOMZtF10xXjTABxmIYN5m+1DIRmEJrdf+I6KdGQqfsWWf/F44eiyrBZ0JztJHh
         Iy79RXgg0FIllAWeaRjYoY3IECIry+OpPX1/lCETDy8I0cIK2fjCaN8omKu8iywZwBNm
         poKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e33si15379747pld.397.2019.01.28.10.15.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 10:15:16 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 32F7E25CE;
	Mon, 28 Jan 2019 18:15:15 +0000 (UTC)
Date: Mon, 28 Jan 2019 10:15:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, Arkadiusz =?UTF-8?Q?Mi=C5=9Bkiewicz?=
 <a.miskiewicz@gmail.com>, Tejun Heo <tj@kernel.org>,
 cgroups@vger.kernel.org, Aleksa Sarai <asarai@suse.de>, Jay Kamat
 <jgkamat@fb.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner
 <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, Linus Torvalds
 <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
Subject: Re: [PATCH v3] oom, oom_reaper: do not enqueue same task twice
Message-Id: <20190128101513.f35752d6210f0781d0de8d17@linux-foundation.org>
In-Reply-To: <e865a044-2c10-9858-f4ef-254bc71d6cc2@i-love.sakura.ne.jp>
References: <a95d004a-4358-7efc-6d21-12aac4411b32@gmail.com>
	<480296c4-ed7a-3265-e84a-298e42a0f1d5@I-love.SAKURA.ne.jp>
	<6da6ca69-5a6e-a9f6-d091-f89a8488982a@gmail.com>
	<72aa8863-a534-b8df-6b9e-f69cf4dd5c4d@i-love.sakura.ne.jp>
	<33a07810-6dbc-36be-5bb6-a279773ccf69@i-love.sakura.ne.jp>
	<34e97b46-0792-cc66-e0f2-d72576cdec59@i-love.sakura.ne.jp>
	<2b0c7d6c-c58a-da7d-6f0a-4900694ec2d3@gmail.com>
	<1d161137-55a5-126f-b47e-b2625bd798ca@i-love.sakura.ne.jp>
	<20190127083724.GA18811@dhcp22.suse.cz>
	<ec0d0580-a2dd-f329-9707-0cb91205a216@i-love.sakura.ne.jp>
	<20190127114021.GB18811@dhcp22.suse.cz>
	<e865a044-2c10-9858-f4ef-254bc71d6cc2@i-love.sakura.ne.jp>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 27 Jan 2019 23:57:38 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:

> Arkadiusz reported that enabling memcg's group oom killing causes
> strange memcg statistics where there is no task in a memcg despite
> the number of tasks in that memcg is not 0. It turned out that there
> is a bug in wake_oom_reaper() which allows enqueuing same task twice
> which makes impossible to decrease the number of tasks in that memcg
> due to a refcount leak.
> 
> This bug existed since the OOM reaper became invokable from
> task_will_free_mem(current) path in out_of_memory() in Linux 4.7,
> but memcg's group oom killing made it easier to trigger this bug by
> calling wake_oom_reaper() on the same task from one out_of_memory()
> request.
> 
> Fix this bug using an approach used by commit 855b018325737f76
> ("oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task").
> As a side effect of this patch, this patch also avoids enqueuing
> multiple threads sharing memory via task_will_free_mem(current) path.
> 

Do we think this is serious enough to warrant a -stable backport?

