Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 884376B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 18:26:15 -0400 (EDT)
Received: by qgf60 with SMTP id 60so53163493qgf.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 15:26:15 -0700 (PDT)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com. [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id 66si3493189qkx.102.2015.03.25.15.26.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 15:26:14 -0700 (PDT)
Received: by qgf60 with SMTP id 60so53162933qgf.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 15:26:14 -0700 (PDT)
Date: Wed, 25 Mar 2015 18:26:11 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH v2 18/18] mm: vmscan: disable memcg direct reclaim stalling
 if cgroup writeback support is in use
Message-ID: <20150325222611.GS3880@htj.duckdns.org>
References: <1427087267-16592-1-git-send-email-tj@kernel.org>
 <1427087267-16592-19-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427087267-16592-19-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Vladimir Davydov <vdavydov@parallels.com>

