Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E42DD6B0273
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 06:30:52 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c8-v6so1956160edt.23
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 03:30:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d20-v6si3567554edr.307.2018.11.01.03.30.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 03:30:51 -0700 (PDT)
Date: Thu, 1 Nov 2018 11:30:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v15 1/2] Reorganize the oom report in dump_header
Message-ID: <20181101103050.GG23921@dhcp22.suse.cz>
References: <1538226387-16600-1-git-send-email-ufo19890607@gmail.com>
 <20181031135049.GO32673@dhcp22.suse.cz>
 <CAHCio2jpqfdgrqOqyXQ=HUc-9kzDmtaYXH+9juVQS6hBHhSdPA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHCio2jpqfdgrqOqyXQ=HUc-9kzDmtaYXH+9juVQS6hBHhSdPA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Thu 01-11-18 18:09:39, c|1e??e?(R) wrote:
> Hi Michal
> The null pointer is possible when calling the dump_header, this bug was
> detected by LKP. Below is the context 3 months ago.

Yeah I remember it was 0day report but I coundn't find it in my email
archive. Do you happen to have a message-id?

Anyway
        if (__ratelimit(&oom_rs))
                dump_header(oc, p);
+       if (oc)
+               dump_oom_summary(oc, victim);

Clearly cannot solve any NULL ptr because oc is never NULL unless I am
missing something terribly.
-- 
Michal Hocko
SUSE Labs
