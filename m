Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0E3856B0070
	for <linux-mm@kvack.org>; Wed, 27 May 2015 20:03:14 -0400 (EDT)
Received: by qcmi9 with SMTP id i9so11141837qcm.0
        for <linux-mm@kvack.org>; Wed, 27 May 2015 17:03:13 -0700 (PDT)
Received: from mail-qg0-x234.google.com (mail-qg0-x234.google.com. [2607:f8b0:400d:c04::234])
        by mx.google.com with ESMTPS id j37si612872qge.110.2015.05.27.17.03.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 17:03:12 -0700 (PDT)
Received: by qgg60 with SMTP id 60so10139662qgg.2
        for <linux-mm@kvack.org>; Wed, 27 May 2015 17:03:12 -0700 (PDT)
Date: Wed, 27 May 2015 20:03:09 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH v5 7/9] writeback: add lockdep annotation to inode_to_wb()
Message-ID: <20150528000309.GU7099@htj.duckdns.org>
References: <1432334183-6324-1-git-send-email-tj@kernel.org>
 <1432334183-6324-8-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432334183-6324-8-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

