Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id BFBB56B0253
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 07:21:10 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4so16005821wml.0
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 04:21:10 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id cf10si5892801wjc.162.2016.08.19.04.21.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 04:21:09 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id i5so3035922wmg.2
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 04:21:09 -0700 (PDT)
Date: Fri, 19 Aug 2016 13:21:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] arm64/hugetlb enable gigantic hugepage
Message-ID: <20160819112107.GG32619@dhcp22.suse.cz>
References: <1471521929-9207-1-git-send-email-xieyisheng1@huawei.com>
 <20160819102551.GA32632@dhcp22.suse.cz>
 <bfb23f62-4308-0ca1-e7ed-e8c686a946ea@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bfb23f62-4308-0ca1-e7ed-e8c686a946ea@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: akpm@linux-foundation.org, guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 19-08-16 19:08:51, Yisheng Xie wrote:
> 
> 
> On 2016/8/19 18:25, Michal Hocko wrote:
> > On Thu 18-08-16 20:05:29, Xie Yisheng wrote:
> >> As we know, arm64 also support gigantic hugepage eg. 1G.
> > 
> > Well, I do not know that. How can I check?
> > 
> Hi Michal,
> Thank you for your reply.
> Maybe you can check the setup_hugepagesz()

OK, I see. The support was added by 084bd29810a5 ("ARM64: mm: HugeTLB
support.") in 3.11 but this got later broken. I suspect 944d9fec8d7a
("hugetlb: add support for gigantic page allocation at runtime") in
3.16 but this would require double checking. Information like this would
be really helpful in the changelog...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
