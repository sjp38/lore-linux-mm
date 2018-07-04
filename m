Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6EDD56B0269
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 04:17:13 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z11-v6so1881771edq.17
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 01:17:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s4-v6si2502993edh.359.2018.07.04.01.17.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 01:17:12 -0700 (PDT)
Date: Wed, 4 Jul 2018 10:17:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v11 1/2] Refactor part of the oom report in dump_header
Message-ID: <20180704081710.GH22503@dhcp22.suse.cz>
References: <1530376739-20459-1-git-send-email-ufo19890607@gmail.com>
 <CAHp75VdaEJgYFUX_MkthFPhimVtJStcinm1P4S-iGfJHvSeiyA@mail.gmail.com>
 <CAHCio2jv-xtnNbJ8beokueh-VQ6zZgF1hAFBJKHCNyuOuz2KxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHCio2jv-xtnNbJ8beokueh-VQ6zZgF1hAFBJKHCNyuOuz2KxA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Cc: andy.shevchenko@gmail.com, akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Wed 04-07-18 10:25:30, c|1e??e?(R) wrote:
> Hi Andy
> The const char array need to be used by the new func
> mem_cgroup_print_oom_context and some funcs in oom_kill.c in the
> second patch.

Just declare it in oom.h and define in oom.c
-- 
Michal Hocko
SUSE Labs
