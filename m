Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 227516B0008
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 15:53:01 -0500 (EST)
Received: by mail-qk0-f174.google.com with SMTP id n135so88019607qka.2
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 12:53:01 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id e38si71850974qgd.22.2015.12.29.12.53.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Dec 2015 12:53:00 -0800 (PST)
Subject: Re: [PATCH 0/2] THP mlock fix
References: <1451421990-32297-1-git-send-email-kirill.shutemov@linux.intel.com>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <5682F2A9.7090607@oracle.com>
Date: Tue, 29 Dec 2015 15:52:57 -0500
MIME-Version: 1.0
In-Reply-To: <1451421990-32297-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

On 12/29/2015 03:46 PM, Kirill A. Shutemov wrote:
> Hi Andrew,
> 
> There are two patches below. I believe either of the would fix the bug
> reported by Sasha, but it worth applying both.
> 
> Sasha, as I cannot trigger the bug, I would like to have your Tested-by.
> 
> Kirill A. Shutemov (2):
>   mm, oom: skip mlocked VMAs in __oom_reap_vmas()
>   mm, thp: clear PG_mlocked when last mapping gone
> 
>  mm/oom_kill.c | 7 +++++++
>  mm/rmap.c     | 3 +++
>  2 files changed, 10 insertions(+)
> 

Fixed for me.

	Tested-by: Sasha Levin <sasha.levin@oracle.com>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
