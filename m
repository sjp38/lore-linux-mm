Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0019003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 04:49:37 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so81926583wib.1
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 01:49:36 -0700 (PDT)
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id dl3si12212670wib.41.2015.07.20.01.49.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jul 2015 01:49:35 -0700 (PDT)
Received: by wgav7 with SMTP id v7so59440256wga.2
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 01:49:35 -0700 (PDT)
Date: Mon, 20 Jul 2015 10:49:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory
 feature
Message-ID: <20150720084932.GC1211@dhcp22.suse.cz>
References: <1437114578-2502-1-git-send-email-pintu.k@samsung.com>
 <1437366544-32673-1-git-send-email-pintu.k@samsung.com>
 <20150720082810.GG2561@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150720082810.GG2561@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Pintu Kumar <pintu.k@samsung.com>, akpm@linux-foundation.org, corbet@lwn.net, vbabka@suse.cz, gorcunov@openvz.org, emunson@akamai.com, kirill.shutemov@linux.intel.com, standby24x7@gmail.com, hannes@cmpxchg.org, vdavydov@parallels.com, hughd@google.com, minchan@kernel.org, tj@kernel.org, rientjes@google.com, xypron.glpk@gmx.de, dzickus@redhat.com, prarit@redhat.com, ebiederm@xmission.com, rostedt@goodmis.org, uobergfe@redhat.com, paulmck@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, ddstreet@ieee.org, sasha.levin@oracle.com, koct9i@gmail.com, cj@linux.com, opensource.ganesh@gmail.com, vinmenon@codeaurora.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, qiuxishi@huawei.com, Valdis.Kletnieks@vt.edu, cpgs@samsung.com, pintu_agarwal@yahoo.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, iqbal.ams@samsung.com, pintu.ping@gmail.com, pintu.k@outlook.com

On Mon 20-07-15 09:28:10, Mel Gorman wrote:
[...]
> If high-order allocation latency or reliability is important then you
> really need a different solution because unless this thing runs
> continually to keep memory unused then it'll eventually fail hard and
> the system will perform poorly in the meantime.

Completely agreed. E.g. Vlastimil was suggesting a background compaction
daemon which might be a way to go.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
