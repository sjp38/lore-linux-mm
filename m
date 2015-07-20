Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A36F06B0270
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 18:43:29 -0400 (EDT)
Received: by padck2 with SMTP id ck2so107465844pad.0
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 15:43:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id re6si4681967pab.88.2015.07.20.15.43.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jul 2015 15:43:28 -0700 (PDT)
Date: Mon, 20 Jul 2015 15:43:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5] memcg: export struct mem_cgroup
Message-Id: <20150720154327.97fd5ca81fe6ce50e4a631ff@linux-foundation.org>
In-Reply-To: <20150720112356.GF1211@dhcp22.suse.cz>
References: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
	<1436958885-18754-2-git-send-email-mhocko@kernel.org>
	<20150715135711.1778a8c08f2ea9560a7c1f6f@linux-foundation.org>
	<20150716071948.GC3077@dhcp22.suse.cz>
	<20150716143433.e43554a19b1c89a8524020cb@linux-foundation.org>
	<20150716225639.GA11131@cmpxchg.org>
	<20150716160358.de3404c44ba29dc132032bbc@linux-foundation.org>
	<20150717122819.GA14895@cmpxchg.org>
	<20150720112356.GF1211@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 20 Jul 2015 13:23:56 +0200 Michal Hocko <mhocko@kernel.org> wrote:

>  I do not think we want two sets of header
> files - one for mm and other for other external users.

We're already doing this (mm/*.h) and it works well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
