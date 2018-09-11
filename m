Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id B24E08E0002
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 08:41:07 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id d63-v6so4803482lfg.9
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 05:41:07 -0700 (PDT)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id a16-v6si20409907ljj.172.2018.09.11.05.41.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 05:41:06 -0700 (PDT)
Subject: Re: [PATCH RFC] mm: don't raise MEMCG_OOM event due to failed
 high-order allocation
References: <20180910215622.4428-1-guro@fb.com>
 <20180911121141.GS10951@dhcp22.suse.cz>
From: peter enderborg <peter.enderborg@sony.com>
Message-ID: <0ea4cdbd-dc3f-1b66-8a5f-8d67ab0e2bc9@sony.com>
Date: Tue, 11 Sep 2018 14:41:04 +0200
MIME-Version: 1.0
In-Reply-To: <20180911121141.GS10951@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On 09/11/2018 02:11 PM, Michal Hocko wrote:
> Why is this a problem though? IIRC this event was deliberately placed
> outside of the oom path because we wanted to count allocation failures
> and this is also documented that way
>
>           oom
>                 The number of time the cgroup's memory usage was
>                 reached the limit and allocation was about to fail.
>
>                 Depending on context result could be invocation of OOM
>                 killer and retrying allocation or failing a
>
> One could argue that we do not apply the same logic to GFP_NOWAIT
> requests but in general I would like to see a good reason to change
> the behavior and if it is really the right thing to do then we need to
> update the documentation as well.
>

Why not introduce a MEMCG_ALLOC_FAIL in to memcg_memory_event?
