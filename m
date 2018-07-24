Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0466D6B000C
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 08:00:21 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id t65-v6so2504434iof.23
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 05:00:21 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 71-v6si8079835ioo.101.2018.07.24.05.00.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 05:00:19 -0700 (PDT)
Subject: Re: cgroup-aware OOM killer, how to move forward
References: <20180711223959.GA13981@castle.DHCP.thefacebook.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <9ef76b45-d50f-7dc6-d224-683ab23efdb0@I-love.SAKURA.ne.jp>
Date: Tue, 24 Jul 2018 20:59:58 +0900
MIME-Version: 1.0
In-Reply-To: <20180711223959.GA13981@castle.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, rientjes@google.com, mhocko@kernel.org, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

Roman, will you check this cleanup patch? This patch applies on top of next-20180724.
I assumed that your series do not kill processes which current thread should not
wait for termination.
