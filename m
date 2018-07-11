Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 09E596B0007
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 07:10:23 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a22-v6so9862808eds.13
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 04:10:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s4-v6si1646706edh.359.2018.07.11.04.10.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 04:10:21 -0700 (PDT)
Date: Wed, 11 Jul 2018 13:10:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v13 2/2] Add oom victim's memcg to the oom context
 information
Message-ID: <20180711111019.GK20050@dhcp22.suse.cz>
References: <1531217988-33940-1-git-send-email-ufo19890607@gmail.com>
 <1531217988-33940-2-git-send-email-ufo19890607@gmail.com>
 <20180710120816.GJ14284@dhcp22.suse.cz>
 <CAHCio2jQO58+npS269Ufyg17unHUeKDRpVjS4-ggBEV8xFMMqQ@mail.gmail.com>
 <20180711074933.GA20050@dhcp22.suse.cz>
 <CAHCio2itfdQ-Tk9x=YhZs6dG6GTZXkct++aND=jFC=8ndXq12w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHCio2itfdQ-Tk9x=YhZs6dG6GTZXkct++aND=jFC=8ndXq12w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Wed 11-07-18 18:31:18, c|1e??e?(R) wrote:
> Hi Michal
> 
> I think the single line output you want is just like that:
> 
> oom-kill:constraint=<constraint>,nodemask=<nodemask>,cpuset=<cpuset>,mems_allowed=<mems_allowed>,oom_memcg=<memcg>,task_memcg=<memcg>,task=<comm>,pid=<pid>,uid=<uid>
> 
> Am I right?

exactly.

-- 
Michal Hocko
SUSE Labs
