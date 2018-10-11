Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA4F16B0003
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 02:37:34 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id k66-v6so5296044pga.21
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 23:37:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id t141-v6si7444272pgb.64.2018.10.10.23.37.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 23:37:33 -0700 (PDT)
Message-Id: <201810110637.w9B6b9eH044188@www262.sakura.ne.jp>
Subject: Re: [RFC PATCH] memcg, oom: throttle =?ISO-2022-JP?B?ZHVtcF9oZWFkZXIgZm9y?=
 =?ISO-2022-JP?B?IG1lbWNnIG9vbXMgd2l0aG91dCBlbGlnaWJsZSB0YXNrcw==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Thu, 11 Oct 2018 15:37:09 +0900
References: <000000000000dc48d40577d4a587@google.com> <20181010151135.25766-1-mhocko@kernel.org>
In-Reply-To: <20181010151135.25766-1-mhocko@kernel.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, Michal Hocko <mhocko@suse.com>, guro@fb.com, hannes@cmpxchg.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com

Michal Hocko wrote:
> Once we are here, make sure that the reason to trigger the OOM is
> printed without ratelimiting because this is really valuable to
> debug what happened.

Here is my version.
