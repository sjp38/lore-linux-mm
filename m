Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 865F06B0036
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 17:59:19 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kx10so2743653pab.39
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 14:59:15 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id pn4si18369931pac.216.2014.04.30.14.59.13
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 14:59:13 -0700 (PDT)
Date: Wed, 30 Apr 2014 14:59:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-Id: <20140430145910.c080164bc198485730d82ee0@linux-foundation.org>
In-Reply-To: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, 28 Apr 2014 14:26:41 +0200 Michal Hocko <mhocko@suse.cz> wrote:

> The series is based on top of the current mmotm tree. Once the series
> gets accepted I will post a patch which will mark the soft limit as
> deprecated with a note that it will be eventually dropped. Let me know
> if you would prefer to have such a patch a part of the series.

Yes please, we may as well get it all in there.

> Thoughts?

I suspect it's a bit early for me to be grabbing these, but I did it anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
