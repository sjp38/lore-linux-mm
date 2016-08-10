Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id AFA556B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 15:43:09 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id g67so101517438qkf.1
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 12:43:09 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id 2si27736880qtv.138.2016.08.10.12.43.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 12:43:08 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id v123so885997qkh.3
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 12:43:08 -0700 (PDT)
Date: Wed, 10 Aug 2016 15:43:06 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC][PATCH] cgroup_threadgroup_rwsem - affects scalability and
 OOM
Message-ID: <20160810194306.GP25053@mtj.duckdns.org>
References: <4717ef90-ca86-4a34-c63a-94b8b4bfaaec@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4717ef90-ca86-4a34-c63a-94b8b4bfaaec@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: cgroups@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello,

Edited subject and description and applied the patch to
cgroup/for-4.8-fixes w/ stable cc'd.

Thanks.
------ 8< ------
