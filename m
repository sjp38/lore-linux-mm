Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id BD7686B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 16:44:22 -0400 (EDT)
Received: by mail-yh0-f47.google.com with SMTP id f73so548733yha.20
        for <linux-mm@kvack.org>; Wed, 05 Jun 2013 13:44:21 -0700 (PDT)
Message-ID: <51AFA185.9000909@gmail.com>
Date: Wed, 05 Jun 2013 16:37:25 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] mm: remove ZONE_RECLAIM_LOCKED
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com> <1370445037-24144-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1370445037-24144-2-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, kosaki.motohiro@gmail.com, Christoph Lameter <cl@linux.com>

(6/5/13 11:10 AM), Andrea Arcangeli wrote:
> Zone reclaim locked breaks zone_reclaim_mode=1. If more than one
> thread allocates memory at the same time, it forces a premature
> allocation into remote NUMA nodes even when there's plenty of clean
> cache to reclaim in the local nodes.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

You should Christoph Lameter who make this lock. I've CCed. I couldn't 
find any problem in this removing. But I also didn't find a reason why 
this lock is needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
