Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 370CB6B006E
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 18:39:53 -0400 (EDT)
Received: by qgfa8 with SMTP id a8so65052727qgf.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 15:39:53 -0700 (PDT)
Received: from mail-qg0-x231.google.com (mail-qg0-x231.google.com. [2607:f8b0:400d:c04::231])
        by mx.google.com with ESMTPS id 36si2603788qgk.31.2015.03.25.15.39.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 15:39:52 -0700 (PDT)
Received: by qgep97 with SMTP id p97so68769946qge.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 15:39:52 -0700 (PDT)
Date: Wed, 25 Mar 2015 18:39:49 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 1.5/18] writeback: clean up wb_dirty_limit()
Message-ID: <20150325223949.GT3880@htj.duckdns.org>
References: <1427087267-16592-1-git-send-email-tj@kernel.org>
 <1427087267-16592-2-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427087267-16592-2-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

