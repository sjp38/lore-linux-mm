Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9276B025E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 11:09:09 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id c2so58393813vkg.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 08:09:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u184si22493309qhe.36.2016.06.15.08.09.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 08:09:08 -0700 (PDT)
Date: Wed, 15 Jun 2016 17:09:03 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 0/10 -v4] Handle oom bypass more gracefully
Message-ID: <20160615150903.GE7944@redhat.com>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09, Michal Hocko wrote:
>
> this is the v4 version of the patchse.

I would like to ack this series even if I do not pretend I understand
all implications.

But imo every change makes sense and this version adresses my previous
comments, so FWIW:

Acked-by: Oleg Nesterov <oleg@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
