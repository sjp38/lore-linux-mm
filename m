Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 279F66B000D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 06:31:32 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id n40-v6so5179090lfi.17
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 03:31:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s86-v6sor4829950lfk.46.2018.07.11.03.31.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 03:31:30 -0700 (PDT)
MIME-Version: 1.0
References: <1531217988-33940-1-git-send-email-ufo19890607@gmail.com>
 <1531217988-33940-2-git-send-email-ufo19890607@gmail.com> <20180710120816.GJ14284@dhcp22.suse.cz>
 <CAHCio2jQO58+npS269Ufyg17unHUeKDRpVjS4-ggBEV8xFMMqQ@mail.gmail.com> <20180711074933.GA20050@dhcp22.suse.cz>
In-Reply-To: <20180711074933.GA20050@dhcp22.suse.cz>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Wed, 11 Jul 2018 18:31:18 +0800
Message-ID: <CAHCio2itfdQ-Tk9x=YhZs6dG6GTZXkct++aND=jFC=8ndXq12w@mail.gmail.com>
Subject: Re: [PATCH v13 2/2] Add oom victim's memcg to the oom context information
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

Hi Michal

I think the single line output you want is just like that:

oom-kill:constraint=<constraint>,nodemask=<nodemask>,cpuset=<cpuset>,mems_allowed=<mems_allowed>,oom_memcg=<memcg>,task_memcg=<memcg>,task=<comm>,pid=<pid>,uid=<uid>

Am I right?
