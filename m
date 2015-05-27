Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 22C7B6B00BA
	for <linux-mm@kvack.org>; Wed, 27 May 2015 12:13:51 -0400 (EDT)
Received: by qgg60 with SMTP id 60so5429326qgg.2
        for <linux-mm@kvack.org>; Wed, 27 May 2015 09:13:51 -0700 (PDT)
Received: from mail-qc0-x232.google.com (mail-qc0-x232.google.com. [2607:f8b0:400d:c01::232])
        by mx.google.com with ESMTPS id 184si8805375qhu.27.2015.05.27.09.13.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 09:13:49 -0700 (PDT)
Received: by qcmi9 with SMTP id i9so5977898qcm.0
        for <linux-mm@kvack.org>; Wed, 27 May 2015 09:13:48 -0700 (PDT)
Date: Wed, 27 May 2015 12:13:44 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH v2 11/51] memcg: implement mem_cgroup_css_from_page()
Message-ID: <20150527161344.GO7099@htj.duckdns.org>
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

