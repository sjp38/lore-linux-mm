Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id F1B8C6B0031
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 14:16:49 -0400 (EDT)
Date: Thu, 6 Jun 2013 18:16:48 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH 1/7] mm: remove ZONE_RECLAIM_LOCKED
In-Reply-To: <CAHGf_=pXjSjZLNEDdbet1633cKtdPR6pqgO-WNVeH3DaBbbVGQ@mail.gmail.com>
Message-ID: <0000013f1ab49054-df10882f-1d77-4d0b-88b1-f7b8774050ef-000000@email.amazonses.com>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com> <1370445037-24144-2-git-send-email-aarcange@redhat.com> <51AFA185.9000909@gmail.com> <0000013f161c3f42-14ae4d9d-fd85-47dd-ba80-896e1e84a6fe-000000@email.amazonses.com> <51AFA786.1040608@gmail.com>
 <0000013f19d7a21d-0bc478a9-c65b-4d66-a774-266b17bcde2a-000000@email.amazonses.com> <CAHGf_=pXjSjZLNEDdbet1633cKtdPR6pqgO-WNVeH3DaBbbVGQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On Thu, 6 Jun 2013, KOSAKI Motohiro wrote:

> At zone reclaim was created, 16 (1<<4) concurrent reclaim may drop all page
> cache because zone reclaim uses priority 4 by default. However, now we have
> reckaim bail out logic. So, priority 4 doesn't directly mean each zone reclaim
> drop 1/16 caches.

Sounds good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
