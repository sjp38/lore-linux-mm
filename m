Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id B69986B0069
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 03:20:36 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id h11so4268800wiw.5
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 00:20:36 -0700 (PDT)
Received: from cpsmtpb-ews03.kpnxchange.com (cpsmtpb-ews03.kpnxchange.com. [213.75.39.6])
        by mx.google.com with ESMTP id fs5si8450170wjb.119.2014.10.16.00.20.34
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 00:20:35 -0700 (PDT)
Message-ID: <1413444034.2128.27.camel@x220>
Subject: Re: [patch 3/3] kernel: res_counter: remove the unused API
From: Paul Bolle <pebolle@tiscali.nl>
Date: Thu, 16 Oct 2014 09:20:34 +0200
In-Reply-To: <1413251163-8517-4-git-send-email-hannes@cmpxchg.org>
References: <1413251163-8517-1-git-send-email-hannes@cmpxchg.org>
	 <1413251163-8517-4-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Valentin Rothberg <valentinrothberg@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2014-10-13 at 21:46 -0400, Johannes Weiner wrote:
> All memory accounting and limiting has been switched over to the
> lockless page counters.  Bye, res_counter!
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Vladimir Davydov <vdavydov@parallels.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>

This patch landed in today's linux-next (ie, next 20141016).

>  Documentation/cgroups/resource_counter.txt | 197 -------------------------
>  include/linux/res_counter.h                | 223 -----------------------------
>  init/Kconfig                               |   6 -
>  kernel/Makefile                            |   1 -
>  kernel/res_counter.c                       | 211 ---------------------------
>  5 files changed, 638 deletions(-)
>  delete mode 100644 Documentation/cgroups/resource_counter.txt
>  delete mode 100644 include/linux/res_counter.h
>  delete mode 100644 kernel/res_counter.c

There's a last reference to CONFIG_RESOURCE_COUNTERS in
Documentation/cgroups/memory.txt. That reference could be dropped too,
couldn't it?


Paul Bolle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
