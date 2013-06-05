Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id E0A4C6B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 16:51:58 -0400 (EDT)
Date: Wed, 5 Jun 2013 20:51:57 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH 1/7] mm: remove ZONE_RECLAIM_LOCKED
In-Reply-To: <51AFA185.9000909@gmail.com>
Message-ID: <0000013f161c3f42-14ae4d9d-fd85-47dd-ba80-896e1e84a6fe-000000@email.amazonses.com>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com> <1370445037-24144-2-git-send-email-aarcange@redhat.com> <51AFA185.9000909@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On Wed, 5 Jun 2013, KOSAKI Motohiro wrote:

> (6/5/13 11:10 AM), Andrea Arcangeli wrote:
> > Zone reclaim locked breaks zone_reclaim_mode=1. If more than one
> > thread allocates memory at the same time, it forces a premature
> > allocation into remote NUMA nodes even when there's plenty of clean
> > cache to reclaim in the local nodes.
> >
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>
> You should Christoph Lameter who make this lock. I've CCed. I couldn't
> find any problem in this removing. But I also didn't find a reason why
> this lock is needed.

There was early on an issue with multiple zone reclaims from
different processors causing an extreme slowdown and the system would go
OOM. The flag was used to enforce that only a single zone reclaim pass was
occurring at one time on a zone. This minimized contention and avoided
the failure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
