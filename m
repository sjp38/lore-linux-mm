Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 264BB6B0035
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 19:09:45 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id c9so16806480qcz.3
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 16:09:44 -0800 (PST)
Received: from mail-qc0-x235.google.com (mail-qc0-x235.google.com [2607:f8b0:400d:c01::235])
        by mx.google.com with ESMTPS id h49si16620058qgf.159.2014.02.12.16.09.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 12 Feb 2014 16:09:44 -0800 (PST)
Received: by mail-qc0-f181.google.com with SMTP id e9so16538106qcy.40
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 16:09:43 -0800 (PST)
Date: Wed, 12 Feb 2014 19:09:39 -0500
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH] Revert "cgroup: use an ordered workqueue for cgroup
 destruction"
Message-ID: <20140213000939.GA2916@htj.dyndns.org>
References: <alpine.LSU.2.11.1402061541560.31342@eggly.anvils>
 <20140207164321.GE6963@cmpxchg.org>
 <alpine.LSU.2.11.1402121417230.5029@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1402121417230.5029@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Filipe Brandenburger <filbranden@google.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Markus Blank-Burian <burian@muenster.de>, Shawn Bohrer <shawn.bohrer@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

