Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id A53F06B0006
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:54:51 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id t11-v6so6125645ybi.3
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 09:54:51 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id u62si619606ywa.320.2018.04.10.09.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 09:54:50 -0700 (PDT)
Subject: Re: [PATCH v3 2/3] mm/shmem: update file sealing comments and file
 checking
References: <20180409230505.18953-1-mike.kravetz@oracle.com>
 <20180409230505.18953-3-mike.kravetz@oracle.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <e710688c-1086-f9e4-6589-e4b5641ae30c@oracle.com>
Date: Tue, 10 Apr 2018 10:54:21 -0600
MIME-Version: 1.0
In-Reply-To: <20180409230505.18953-3-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/09/2018 05:05 PM, Mike Kravetz wrote:
> In preparation for memfd code restucture, update comments dealing
> with file sealing to indicate that tmpfs and hugetlbfs are the
> supported filesystems.  Also, change file pointer checks in
> memfd_file_seals_ptr to use defined routines instead of directly
> referencing file_operation structs.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>   mm/shmem.c | 29 +++++++++++++++--------------
>   1 file changed, 15 insertions(+), 14 deletions(-)
>

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
