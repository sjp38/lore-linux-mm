Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9A16B02F6
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 04:45:06 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id k3-v6so13225900ioq.8
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 01:45:06 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id x5-v6si21621533ioa.43.2018.11.06.01.45.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 01:45:04 -0800 (PST)
Subject: Re: [RFC PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
References: <20181022071323.9550-1-mhocko@kernel.org>
 <20181022071323.9550-3-mhocko@kernel.org>
 <20181026142531.GA27370@cmpxchg.org> <20181026192551.GC18839@dhcp22.suse.cz>
 <20181026193304.GD18839@dhcp22.suse.cz>
 <dfafc626-2233-db9b-49fa-9d4bae16d4aa@i-love.sakura.ne.jp>
Message-ID: <c38e352a-dd23-a5e4-ac50-75b557506479@i-love.sakura.ne.jp>
Date: Tue, 6 Nov 2018 18:44:43 +0900
MIME-Version: 1.0
In-Reply-To: <dfafc626-2233-db9b-49fa-9d4bae16d4aa@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

