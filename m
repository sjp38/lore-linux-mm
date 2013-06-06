Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id A7E1C6B0031
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 13:17:35 -0400 (EDT)
Received: by mail-ob0-f171.google.com with SMTP id dn14so5121624obc.30
        for <linux-mm@kvack.org>; Thu, 06 Jun 2013 10:17:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013f19d7a21d-0bc478a9-c65b-4d66-a774-266b17bcde2a-000000@email.amazonses.com>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
 <1370445037-24144-2-git-send-email-aarcange@redhat.com> <51AFA185.9000909@gmail.com>
 <0000013f161c3f42-14ae4d9d-fd85-47dd-ba80-896e1e84a6fe-000000@email.amazonses.com>
 <51AFA786.1040608@gmail.com> <0000013f19d7a21d-0bc478a9-c65b-4d66-a774-266b17bcde2a-000000@email.amazonses.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 6 Jun 2013 13:17:14 -0400
Message-ID: <CAHGf_=pXjSjZLNEDdbet1633cKtdPR6pqgO-WNVeH3DaBbbVGQ@mail.gmail.com>
Subject: Re: [PATCH 1/7] mm: remove ZONE_RECLAIM_LOCKED
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

> How does nr_to_reclaim limit the concurrency of zone reclaim?

No, it doesn't prevent concurrent reclaim itself. It only prevents cuncurrent
reclaim much much pages rather than SWAP_CLUSTER_MAX. note,
zone reclaim uses priority 4 by default.

> What happens if multiple processes are allocating from the same zone and
> they all go into direct reclaim and therefore hit zone reclaim?

At zone reclaim was created, 16 (1<<4) concurrent reclaim may drop all page
cache because zone reclaim uses priority 4 by default. However, now we have
reckaim bail out logic. So, priority 4 doesn't directly mean each zone reclaim
drop 1/16 caches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
