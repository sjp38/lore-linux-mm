Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF6FE6B0006
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 06:45:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t10-v6so271581eds.7
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 03:45:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s7-v6si2910073eda.85.2018.07.23.03.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 03:45:29 -0700 (PDT)
Date: Mon, 23 Jul 2018 12:45:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v14 1/2] Reorganize the oom report in dump_header
Message-ID: <20180723104526.GA31229@dhcp22.suse.cz>
References: <1531825548-27761-1-git-send-email-ufo19890607@gmail.com>
 <20180717111608.GC7193@dhcp22.suse.cz>
 <CAHCio2j3atFwxHwm_zYGtXY4j1MJ8FNcthyXtLCBW19QJLdyuQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHCio2j3atFwxHwm_zYGtXY4j1MJ8FNcthyXtLCBW19QJLdyuQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Mon 23-07-18 10:56:13, c|1e??e?(R) wrote:
> Hi Michal
> OK, thanks. Is there any problems for V14?

I do not know of any. Both patches are sitting in the mmotm tree so they
should be merged in a forseeable future as long as nobody finds any
problems.
-- 
Michal Hocko
SUSE Labs
