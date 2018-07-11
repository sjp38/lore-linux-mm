Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id BCDB26B0003
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 23:39:42 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id v24-v6so2025896ljh.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 20:39:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u22-v6sor3751848ljj.84.2018.07.10.20.39.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Jul 2018 20:39:41 -0700 (PDT)
MIME-Version: 1.0
References: <1531217988-33940-1-git-send-email-ufo19890607@gmail.com>
 <1531217988-33940-2-git-send-email-ufo19890607@gmail.com> <20180710120816.GJ14284@dhcp22.suse.cz>
In-Reply-To: <20180710120816.GJ14284@dhcp22.suse.cz>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Wed, 11 Jul 2018 11:39:29 +0800
Message-ID: <CAHCio2jQO58+npS269Ufyg17unHUeKDRpVjS4-ggBEV8xFMMqQ@mail.gmail.com>
Subject: Re: [PATCH v13 2/2] Add oom victim's memcg to the oom context information
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

Hi Michal
Sorry , I l forget to update the changlog for the second patch, but
the cpuset information is not missing.  Do I still need to make the
v14  or just update the changelog for v13?

Thanks
