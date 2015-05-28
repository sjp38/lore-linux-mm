Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3E2C96B0070
	for <linux-mm@kvack.org>; Wed, 27 May 2015 20:00:08 -0400 (EDT)
Received: by qkoo18 with SMTP id o18so15705947qko.1
        for <linux-mm@kvack.org>; Wed, 27 May 2015 17:00:08 -0700 (PDT)
Received: from mail-qk0-x22d.google.com (mail-qk0-x22d.google.com. [2607:f8b0:400d:c09::22d])
        by mx.google.com with ESMTPS id d89si610756qkh.111.2015.05.27.17.00.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 17:00:06 -0700 (PDT)
Received: by qkdn188 with SMTP id n188so15688425qkd.2
        for <linux-mm@kvack.org>; Wed, 27 May 2015 17:00:06 -0700 (PDT)
Date: Wed, 27 May 2015 20:00:02 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH v4 11/51] memcg: implement mem_cgroup_css_from_page()
Message-ID: <20150528000002.GT7099@htj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-12-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432329245-5844-12-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

