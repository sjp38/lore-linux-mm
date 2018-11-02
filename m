Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9C46B0003
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 04:36:01 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i1-v6so835695edc.1
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 01:36:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g18-v6si7313710ejb.309.2018.11.02.01.35.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 01:35:59 -0700 (PDT)
Date: Fri, 2 Nov 2018 09:34:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v15 1/2] Reorganize the oom report in dump_header
Message-ID: <20181102083413.GR23921@dhcp22.suse.cz>
References: <1538226387-16600-1-git-send-email-ufo19890607@gmail.com>
 <20181031135049.GO32673@dhcp22.suse.cz>
 <CAHCio2jpqfdgrqOqyXQ=HUc-9kzDmtaYXH+9juVQS6hBHhSdPA@mail.gmail.com>
 <20181101103050.GG23921@dhcp22.suse.cz>
 <CAHCio2jZ-RRuJ02ARmio5YON4mn0jwtuK_purFRxqSuVD=JsPA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHCio2jZ-RRuJ02ARmio5YON4mn0jwtuK_purFRxqSuVD=JsPA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Fri 02-11-18 14:18:59, c|1e??e?(R) wrote:
> Hi Michal
> The message-id is as below
> https://lkml.org/lkml/2018/7/31/148

David said
: It's possible that p is NULL when calling dump_header().  In this case we
: do not want to print any line concerning a victim because no oom kill has
: occurred.

This means that we should check for p rather than oc.

-- 
Michal Hocko
SUSE Labs
