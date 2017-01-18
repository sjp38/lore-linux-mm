Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 94E6D6B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 02:22:19 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d185so7225973pgc.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 23:22:19 -0800 (PST)
Received: from out0-151.mail.aliyun.com (out0-151.mail.aliyun.com. [140.205.0.151])
        by mx.google.com with ESMTP id 31si27556520pli.135.2017.01.17.23.22.18
        for <linux-mm@kvack.org>;
        Tue, 17 Jan 2017 23:22:18 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170117221610.22505-1-vbabka@suse.cz> <20170117221610.22505-4-vbabka@suse.cz>
In-Reply-To: <20170117221610.22505-4-vbabka@suse.cz>
Subject: Re: [RFC 3/4] mm, page_alloc: move cpuset seqcount checking to slowpath
Date: Wed, 18 Jan 2017 15:22:13 +0800
Message-ID: <036f01d2715b$97827e80$c6877b80$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vlastimil Babka' <vbabka@suse.cz>, 'Mel Gorman' <mgorman@techsingularity.net>, 'Ganapatrao Kulkarni' <gpkulkarni@gmail.com>
Cc: 'Michal Hocko' <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wednesday, January 18, 2017 6:16 AM Vlastimil Babka wrote: 
> 
> This is a preparation for the following patch to make review simpler. While
> the primary motivation is a bug fix, this could also save some cycles in the
> fast path.
> 
This also gets kswapd involved. 
Dunno how frequent cpuset is changed in real life.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
