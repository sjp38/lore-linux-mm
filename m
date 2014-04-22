Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 958636B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 04:08:45 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id h18so2590325igc.2
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 01:08:45 -0700 (PDT)
Received: from mail-ie0-x22c.google.com (mail-ie0-x22c.google.com [2607:f8b0:4001:c03::22c])
        by mx.google.com with ESMTPS id k7si24584471icu.45.2014.04.22.01.08.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 01:08:44 -0700 (PDT)
Received: by mail-ie0-f172.google.com with SMTP id as1so4922199iec.17
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 01:08:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2c63c535f8202c6b605300a834cdf1c07d1bafc3.1398147734.git.nasa4836@gmail.com>
References: <cover.1398147734.git.nasa4836@gmail.com> <2c63c535f8202c6b605300a834cdf1c07d1bafc3.1398147734.git.nasa4836@gmail.com>
From: Jianyu Zhan <nasa4836@gmail.com>
Date: Tue, 22 Apr 2014 16:08:04 +0800
Message-ID: <CAHz2CGW62TMEVuqj8ixpPP_hOW6r4Q6VkZRtG_kKc6ibd2V=jA@mail.gmail.com>
Subject: Re: [PATCH 2/4] mm/memcontrol.c: use accessor to get id from css
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, kamezawa.hiroyu@jp.fujitsu.com
Cc: Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jianyu Zhan <nasa4836@gmail.com>

On Tue, Apr 22, 2014 at 2:30 PM, Jianyu Zhan <nasa4836@gmail.com> wrote:
> This is a prepared patch for converting from per-cgroup id to
> per-subsystem id.
>
> We should not access per-cgroup id directly, since this is implemetation
> detail. Use the accessor css_from_id() instead.
>
> This patch has no functional change.

Hi,  I'm sorry.  This patch should be applied on top of its previous patch:
https://lkml.org/lkml/2014/4/22/54

Sorry for my fault , not cc'ing this mail-list in that patch.

Thanks,
Jianyu Zhan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
