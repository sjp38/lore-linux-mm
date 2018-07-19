Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id B3A396B0272
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 10:23:58 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e21-v6so5813240itc.5
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 07:23:58 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id o56-v6si4953727jal.32.2018.07.19.07.23.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 07:23:57 -0700 (PDT)
Subject: Re: [patch v3] mm, oom: fix unnecessary killing of additional
 processes
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com>
 <d19d44c3-c8cf-70a1-9b15-c98df233d5f0@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1807181317540.49359@chino.kir.corp.google.com>
 <a78fb992-ad59-0cdb-3c38-8284b2245f21@i-love.sakura.ne.jp>
Message-ID: <9eaea8ee-08e3-2188-a852-60bfaf3693e1@i-love.sakura.ne.jp>
Date: Thu, 19 Jul 2018 23:23:51 +0900
MIME-Version: 1.0
In-Reply-To: <a78fb992-ad59-0cdb-3c38-8284b2245f21@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

David,

Now that your patches are about to be dropped from linux-next.git , please try OOM lockup
(CVE-2016-10723) mitigation patch ( https://marc.info/?l=linux-mm&m=153112243424285&w=4 )
and my cleanup patch ( [PATCH 1/2] at https://marc.info/?l=linux-mm&m=153119509215026&w=4 )
on top of linux.git . And please reply how was the result, for I'm currently asking
Roman whether we can apply these patches before applying the cgroup-aware OOM killer.
