Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B2F66B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 06:51:16 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id b6-v6so811881otk.5
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 03:51:16 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g33-v6si327950otc.320.2018.04.18.03.51.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 03:51:15 -0700 (PDT)
Subject: Re: [PATCH 2/2] fs, elf: drop MAP_FIXED usage from elf_map
References: <20171213092550.2774-1-mhocko@kernel.org>
 <20171213092550.2774-3-mhocko@kernel.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <0b5c541a-91ee-220b-3196-f64264f9f0bc@I-love.SAKURA.ne.jp>
Date: Wed, 18 Apr 2018 19:51:05 +0900
MIME-Version: 1.0
In-Reply-To: <20171213092550.2774-3-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

