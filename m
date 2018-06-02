Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 286BB6B0007
	for <linux-mm@kvack.org>; Sat,  2 Jun 2018 07:19:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c187-v6so16029578pfa.20
        for <linux-mm@kvack.org>; Sat, 02 Jun 2018 04:19:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t70-v6si134027pgc.481.2018.06.02.04.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 02 Jun 2018 04:19:55 -0700 (PDT)
Date: Sat, 2 Jun 2018 04:19:40 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v7 1/2] Add an array of const char and enum
 oom_constraint in memcontrol.h
Message-ID: <20180602111940.GA31754@bombadil.infradead.org>
References: <CAHCio2hrYo6f35cT69+xa5BwUXpwYXXm76GppUBB2WTrKonaFQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHCio2hrYo6f35cT69+xa5BwUXpwYXXm76GppUBB2WTrKonaFQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Sat, Jun 02, 2018 at 07:06:44PM +0800, c|1e??e?(R) wrote:
> From: yuzhoujian <yuzhoujian@didichuxing.com>
> 
> This patch will make some preparation for the follow-up patch: Refactor
> part of the oom report in dump_header. It puts enum oom_constraint in
> memcontrol.h and adds an array of const char for each constraint.

This patch is whitespace damaged.  See the instructions for using git
send-email with gmail: https://git-scm.com/docs/git-send-email

> +static const char * const oom_constraint_text[] = {
> + [CONSTRAINT_NONE] = "CONSTRAINT_NONE",
> + [CONSTRAINT_CPUSET] = "CONSTRAINT_CPUSET",
> + [CONSTRAINT_MEMORY_POLICY] = "CONSTRAINT_MEMORY_POLICY",
> + [CONSTRAINT_MEMCG] = "CONSTRAINT_MEMCG",
> +};
> +

Um, isn't this going to put the strings in every file which includes
memcontrol.h?
