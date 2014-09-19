Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2AD766B0035
	for <linux-mm@kvack.org>; Fri, 19 Sep 2014 09:29:24 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id cc10so2825461wib.14
        for <linux-mm@kvack.org>; Fri, 19 Sep 2014 06:29:23 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id we4si2174269wjb.82.2014.09.19.06.29.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Sep 2014 06:29:22 -0700 (PDT)
Date: Fri, 19 Sep 2014 09:29:19 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: lockless page counters
Message-ID: <20140919132919.GA16184@cmpxchg.org>
References: <1411132928-16143-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411132928-16143-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Dave,

this patch removes the lock you saw with will-it-scale/page_fault2
entirely, is there a chance you could give it a spin?  It's based on
v3.17-rc4-mmots-2014-09-12-17-13-4 and that memcg THP fix.  That
kernel also includes the recent root-memcg revert, so you'd have to
run it in a memcg; which is as easy as:

mkdir /sys/fs/cgroup/memory/foo
echo $$ >/sys/fs/cgroup/memory/foo/tasks
perf record -g -a ./runtest.py page_fault2

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
