Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3696B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 08:03:46 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id w16so79495150lfd.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 05:03:46 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id il10si44091362wjb.167.2016.05.30.05.03.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 05:03:44 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id e3so21955279wme.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 05:03:44 -0700 (PDT)
Date: Mon, 30 May 2016 14:03:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/6] mm, oom: skip over vforked tasks
Message-ID: <20160530120343.GW22928@dhcp22.suse.cz>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
 <1464266415-15558-5-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464266415-15558-5-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

So I've ended up with a replacement for this patch which does the
following:
---
