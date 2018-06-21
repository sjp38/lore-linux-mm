Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id F14AB6B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 01:47:10 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id h38-v6so1163428otb.4
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 22:47:10 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id u32-v6si1424529otc.242.2018.06.20.22.47.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 22:47:09 -0700 (PDT)
Message-Id: <201806210547.w5L5l5Mh029257@www262.sakura.ne.jp>
Subject: [PATCH] Makefile: Fix backtrace breakage
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Thu, 21 Jun 2018 14:47:05 +0900
References: <8fda53b0-9d86-943b-e8b4-fd9d6553f010@i-love.sakura.ne.jp> <20180621001509.GQ19934@dastard>
In-Reply-To: <20180621001509.GQ19934@dastard>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>, "Steven Rostedt (VMware)" <rostedt@goodmis.org>
Cc: Dave Chinner <david@fromorbit.com>, Dave Chinner <dchinner@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Omar Sandoval <osandov@fb.com>

