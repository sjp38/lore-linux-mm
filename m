Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 3E6206B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 17:02:58 -0400 (EDT)
Received: by mail-vc0-f174.google.com with SMTP id kw10so1494731vcb.33
        for <linux-mm@kvack.org>; Wed, 05 Jun 2013 14:02:57 -0700 (PDT)
Message-ID: <51AFA786.1040608@gmail.com>
Date: Wed, 05 Jun 2013 17:03:02 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] mm: remove ZONE_RECLAIM_LOCKED
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com> <1370445037-24144-2-git-send-email-aarcange@redhat.com> <51AFA185.9000909@gmail.com> <0000013f161c3f42-14ae4d9d-fd85-47dd-ba80-896e1e84a6fe-000000@email.amazonses.com>
In-Reply-To: <0000013f161c3f42-14ae4d9d-fd85-47dd-ba80-896e1e84a6fe-000000@email.amazonses.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

(6/5/13 4:51 PM), Christoph Lameter wrote:
> On Wed, 5 Jun 2013, KOSAKI Motohiro wrote:
>
>> (6/5/13 11:10 AM), Andrea Arcangeli wrote:
>>> Zone reclaim locked breaks zone_reclaim_mode=1. If more than one
>>> thread allocates memory at the same time, it forces a premature
>>> allocation into remote NUMA nodes even when there's plenty of clean
>>> cache to reclaim in the local nodes.
>>>
>>> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>>
>> You should Christoph Lameter who make this lock. I've CCed. I couldn't
>> find any problem in this removing. But I also didn't find a reason why
>> this lock is needed.
>
> There was early on an issue with multiple zone reclaims from
> different processors causing an extreme slowdown and the system would go
> OOM. The flag was used to enforce that only a single zone reclaim pass was
> occurring at one time on a zone. This minimized contention and avoided
> the failure.

OK. I've convinced now we can removed because sc->nr_to_reclaim protect us form
this issue.

Thank you, guys.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
