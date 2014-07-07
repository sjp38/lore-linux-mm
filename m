Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6BF900002
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 13:14:21 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id ty20so3147562lab.31
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 10:14:20 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id no1si70210918lbb.27.2014.07.07.10.14.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 10:14:19 -0700 (PDT)
Message-ID: <53BAD567.8060506@parallels.com>
Date: Mon, 7 Jul 2014 21:14:15 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 0/8] memcg: reparent kmem on css offline
References: <cover.1404733720.git.vdavydov@parallels.com> <20140707142506.GB1149@cmpxchg.org>
In-Reply-To: <20140707142506.GB1149@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

07.07.2014 18:25, Johannes Weiner:
> In addition, Tejun made offlined css iterable and split css_tryget()
> and css_tryget_online(), which would allow memcg to pin the css until
> the last charge is gone while continuing to iterate and reclaim it on
> hierarchical pressure, even after it was offlined.

One more question.

With reparenting enabled, the number of cgroups (lruvecs) that must be
iterated on global reclaim is bound by the number of live containers,
while w/o reparenting it's practically unbound, isn't it? Won't it be
the source of latency spikes?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
