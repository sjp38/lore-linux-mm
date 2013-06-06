Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 242236B0034
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 10:15:32 -0400 (EDT)
Date: Thu, 6 Jun 2013 14:15:29 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/7] mm: remove ZONE_RECLAIM_LOCKED
In-Reply-To: <51AFA786.1040608@gmail.com>
Message-ID: <0000013f19d7a21d-0bc478a9-c65b-4d66-a774-266b17bcde2a-000000@email.amazonses.com>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com> <1370445037-24144-2-git-send-email-aarcange@redhat.com> <51AFA185.9000909@gmail.com> <0000013f161c3f42-14ae4d9d-fd85-47dd-ba80-896e1e84a6fe-000000@email.amazonses.com>
 <51AFA786.1040608@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On Wed, 5 Jun 2013, KOSAKI Motohiro wrote:

> > There was early on an issue with multiple zone reclaims from
> > different processors causing an extreme slowdown and the system would go
> > OOM. The flag was used to enforce that only a single zone reclaim pass was
> > occurring at one time on a zone. This minimized contention and avoided
> > the failure.
>
> OK. I've convinced now we can removed because sc->nr_to_reclaim protect us
> form
> this issue.

How does nr_to_reclaim limit the concurrency of zone reclaim?

What happens if multiple processes are allocating from the same zone and
they all go into direct reclaim and therefore hit zone reclaim?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
