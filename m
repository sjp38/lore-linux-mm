Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9456B006E
	for <linux-mm@kvack.org>; Wed, 27 May 2015 13:57:35 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so10294748qkd.2
        for <linux-mm@kvack.org>; Wed, 27 May 2015 10:57:35 -0700 (PDT)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com. [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id f1si8671848qcs.18.2015.05.27.10.57.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 10:57:34 -0700 (PDT)
Received: by qgez61 with SMTP id z61so6652789qge.1
        for <linux-mm@kvack.org>; Wed, 27 May 2015 10:57:34 -0700 (PDT)
Date: Wed, 27 May 2015 13:57:26 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH v3 11/51] memcg: implement mem_cgroup_css_from_page()
Message-ID: <20150527175726.GQ7099@htj.duckdns.org>
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

