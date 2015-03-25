Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 522576B0071
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 18:44:21 -0400 (EDT)
Received: by qgep97 with SMTP id p97so68924910qge.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 15:44:21 -0700 (PDT)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com. [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id j62si3559763qhc.65.2015.03.25.15.44.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 15:44:20 -0700 (PDT)
Received: by qgep97 with SMTP id p97so68924281qge.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 15:44:20 -0700 (PDT)
Date: Wed, 25 Mar 2015 18:44:17 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 9/8] writeback: disassociate inodes from dying bdi_writebacks
Message-ID: <20150325224417.GV3880@htj.duckdns.org>
References: <1427088344-17542-1-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427088344-17542-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

