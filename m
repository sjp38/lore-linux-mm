Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D54AB6B0005
	for <linux-mm@kvack.org>; Fri, 20 May 2016 03:50:37 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m138so5219117lfm.0
        for <linux-mm@kvack.org>; Fri, 20 May 2016 00:50:37 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id ee4si23947387wjd.121.2016.05.20.00.50.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 May 2016 00:50:36 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id 67so3804326wmg.0
        for <linux-mm@kvack.org>; Fri, 20 May 2016 00:50:36 -0700 (PDT)
Date: Fri, 20 May 2016 09:50:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm,oom: speed up select_bad_process() loop.
Message-ID: <20160520075035.GF19172@dhcp22.suse.cz>
References: <1463574024-8372-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160518125138.GH21654@dhcp22.suse.cz>
 <201605182230.IDC73435.MVSOHLFOQFOJtF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605182230.IDC73435.MVSOHLFOQFOJtF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, oleg@redhat.com

Here is a follow up for this patch. As I've mentioned in the other
email, I would like to mark oom victim in the mm_struct but that
requires more changes and the patch simplifies select_bad_process
nicely already so I like this patch even now.
---
