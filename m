Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4BA226B007E
	for <linux-mm@kvack.org>; Tue, 17 May 2016 18:21:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b203so58845656pfb.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 15:21:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id dz4si7321418pab.12.2016.05.17.15.21.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 15:21:40 -0700 (PDT)
Date: Tue, 17 May 2016 15:21:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] oom: consider multi-threaded tasks in
 task_will_free_mem
Message-Id: <20160517152139.fbda59b7c66e8470575050e8@linux-foundation.org>
In-Reply-To: <20160517202856.GF12220@dhcp22.suse.cz>
References: <1460452756-15491-1-git-send-email-mhocko@kernel.org>
	<20160426135752.GC20813@dhcp22.suse.cz>
	<20160517202856.GF12220@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue, 17 May 2016 22:28:56 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> Andrew, this is not in the mmotm tree now because I didn't feel really
> confortable with the patch without Oleg seeing it. But it seems Oleg is
> ok [1] with it so could you push it to Linus along with the rest of oom
> pile please?

Reluctant.  The CONFIG_COMPACTION=n regression which Joonsoo identified
is quite severe.  Before patch: 10000 forks succeed.  After patch: 500
forks fail.  Ouch.

How can we merge such a thing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
