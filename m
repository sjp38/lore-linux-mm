Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 54C0B6B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 07:32:00 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id w107so102130660ota.6
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 04:32:00 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0105.outbound.protection.outlook.com. [104.47.2.105])
        by mx.google.com with ESMTPS id e85si5944241oig.332.2017.01.23.04.31.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 Jan 2017 04:31:59 -0800 (PST)
Subject: Re: [PATCH 0/3] userfaultfd: non-cooperative: add madvise() event for
 MADV_REMOVE request
References: <1484814154-1557-1-git-send-email-rppt@linux.vnet.ibm.com>
From: Pavel Emelyanov <xemul@virtuozzo.com>
Message-ID: <5885F8D2.2010305@virtuozzo.com>
Date: Mon, 23 Jan 2017 15:36:34 +0300
MIME-Version: 1.0
In-Reply-To: <1484814154-1557-1-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org

On 01/19/2017 11:22 AM, Mike Rapoport wrote:
> Hi,
> 
> These patches add notification of madvise(MADV_REMOVE) event to
> non-cooperative userfaultfd monitor.
> 
> The first pacth renames EVENT_MADVDONTNEED to EVENT_REMOVE along with
> relevant functions and structures. Using _REMOVE instead of _MADVDONTNEED
> describes the event semantics more clearly and I hope it's not too late for
> such change in the ABI.
> 
> The patches are against current -mm tree.
> 
> Mike Rapoport (3):
>   userfaultfd: non-cooperative: rename *EVENT_MADVDONTNEED to *EVENT_REMOVE
>   userfaultfd: non-cooperative: add madvise() event for MADV_REMOVE request
>   userfaultfd: non-cooperative: selftest: enable REMOVE event test for shmem

Acked-by: Pavel Emelyanov <xemul@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
