Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE656B0007
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 19:40:45 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id d9-v6so3856232plj.4
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 16:40:45 -0700 (PDT)
Received: from out4438.biz.mail.alibaba.com (out4438.biz.mail.alibaba.com. [47.88.44.38])
        by mx.google.com with ESMTPS id x7si3883498pge.559.2018.04.19.16.40.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 16:40:44 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [LSF/MM] May I sneak in a new topic to MM track?
Message-ID: <72f799d6-2b50-3185-888f-48438d33f817@linux.alibaba.com>
Date: Thu, 19 Apr 2018 16:40:15 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, mhocko@kernel.org, Rik van Riel <riel@redhat.com>

Hi folks,


I posted a patch series about mmap_sem scalability 
(https://lkml.org/lkml/2018/3/20/786), and got a lot great feedback. I'm 
working on v2 now (a little bit behind).A  Could we sneak this in if 
anyone is interested? I saw Laurent has a topic about mmap_sem too, I'm 
supposed it is speculative page fault related.


Thanks,

Yang
