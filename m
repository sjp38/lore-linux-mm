Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 516346B0007
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 03:53:51 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t11-v6so9659144edq.1
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 00:53:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 37-v6si605957edt.319.2018.07.11.00.53.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 00:53:50 -0700 (PDT)
Date: Wed, 11 Jul 2018 09:53:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v13 2/2] Add oom victim's memcg to the oom context
 information
Message-ID: <20180711074933.GA20050@dhcp22.suse.cz>
References: <1531217988-33940-1-git-send-email-ufo19890607@gmail.com>
 <1531217988-33940-2-git-send-email-ufo19890607@gmail.com>
 <20180710120816.GJ14284@dhcp22.suse.cz>
 <CAHCio2jQO58+npS269Ufyg17unHUeKDRpVjS4-ggBEV8xFMMqQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHCio2jQO58+npS269Ufyg17unHUeKDRpVjS4-ggBEV8xFMMqQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Wed 11-07-18 11:39:29, c|1e??e?(R) wrote:
> Hi Michal
> Sorry , I l forget to update the changlog for the second patch, but
> the cpuset information is not missing.

The cpuset information is missing in the changelog.

> Do I still need to make the
> v14  or just update the changelog for v13?

Wait for more feedback for few days. If there are no other concerns just
repost this patch 2. Btw. I still think that it would be more logical
to print cpuset before memcg info. But I will not insist.
-- 
Michal Hocko
SUSE Labs
