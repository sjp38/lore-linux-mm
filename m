Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 59D326B0006
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 07:16:38 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id v15-v6so24737743edm.13
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 04:16:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f20-v6si3637303edt.166.2018.10.22.04.16.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 04:16:37 -0700 (PDT)
Date: Mon, 22 Oct 2018 13:16:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH v2 1/2] mm, oom: marks all killed tasks as oom victims
Message-ID: <20181022111636.GA18839@dhcp22.suse.cz>
References: <20181022071323.9550-1-mhocko@kernel.org>
 <20181022071323.9550-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181022071323.9550-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Updated version
