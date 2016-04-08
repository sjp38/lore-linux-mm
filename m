Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id D05106B025E
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 09:14:21 -0400 (EDT)
Received: by mail-wm0-f45.google.com with SMTP id n3so22191237wmn.0
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 06:14:21 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id n127si2942845wma.88.2016.04.08.06.14.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Apr 2016 06:14:20 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id y144so4278955wmd.0
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 06:14:20 -0700 (PDT)
Date: Fri, 8 Apr 2016 15:14:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] oom, oom_reaper: Try to reap tasks which skip
 regular OOM killer path
Message-ID: <20160408131418.GJ29820@dhcp22.suse.cz>
References: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
 <1459951996-12875-3-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459951996-12875-3-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>

Andrew, could you fold this in?
---
