Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 11A7E6B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 11:46:53 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id z11so3951860lbi.12
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 08:46:53 -0700 (PDT)
Received: from forward-corp1e.mail.yandex.net (forward-corp1e.mail.yandex.net. [77.88.60.199])
        by mx.google.com with ESMTPS id 5si5391186lay.26.2014.04.28.08.46.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Apr 2014 08:46:52 -0700 (PDT)
From: Roman Gushchin <klamm@yandex-team.ru>
In-Reply-To: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
MIME-Version: 1.0
Message-Id: <10861398700008@webcorp2f.yandex-team.ru>
Date: Mon, 28 Apr 2014 19:46:48 +0400
Content-Transfer-Encoding: 7bit
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

28.04.2014, 16:27, "Michal Hocko" <mhocko@suse.cz>:
> The series is based on top of the current mmotm tree. Once the series
> gets accepted I will post a patch which will mark the soft limit as
> deprecated with a note that it will be eventually dropped. Let me know
> if you would prefer to have such a patch a part of the series.
>
> Thoughts?


Looks good to me.

The only question is: are there any ideas how the hierarchy support
will be used in this case in practice?
Will someone set low limit for non-leaf cgroups? Why?

Thanks,
Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
