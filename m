Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6156B0007
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 19:40:32 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id h141so2669286qke.6
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 16:40:32 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id j18si1875789qtc.293.2018.04.17.16.40.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 16:40:31 -0700 (PDT)
Subject: Re: [PATCH v4 2/3] mm/shmem: update file sealing comments and file
 checking
References: <20180415182119.4517-1-mike.kravetz@oracle.com>
 <20180415182119.4517-3-mike.kravetz@oracle.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <4863ad78-4b1e-33bf-c38a-b412e5330dd2@oracle.com>
Date: Tue, 17 Apr 2018 17:40:02 -0600
MIME-Version: 1.0
In-Reply-To: <20180415182119.4517-3-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/15/2018 12:21 PM, Mike Kravetz wrote:
> In preparation for memfd code restructure, update comments,
> definitions and function names dealing with file sealing to
> indicate that tmpfs and hugetlbfs are the supported filesystems.
> Also, change file pointer checks in memfd_file_seals_ptr
> to use defined interfaces instead of directly referencing
> file_operation structs.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>   mm/shmem.c | 50 ++++++++++++++++++++++++++------------------------
>   1 file changed, 26 insertions(+), 24 deletions(-)

Looks good.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
