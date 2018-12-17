Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 47F3D8E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 17:53:00 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id f24so13584144ioh.21
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 14:53:00 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id y184si304322itb.86.2018.12.17.14.52.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 14:52:59 -0800 (PST)
Subject: Re: [PATCH] mm: Remove __hugepage_set_anon_rmap()
References: <154504875359.30235.6237926369392564851.stgit@localhost.localdomain>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <6852d074-74fb-6eb7-69b0-2d1f35064b84@oracle.com>
Date: Mon, 17 Dec 2018 14:52:53 -0800
MIME-Version: 1.0
In-Reply-To: <154504875359.30235.6237926369392564851.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, jglisse@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/17/18 4:13 AM, Kirill Tkhai wrote:
> This function is identical to __page_set_anon_rmap()
> since the time, when it was introduced (8 years ago).
> The patch removes the function, and makes its users
> to use __page_set_anon_rmap() instead.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

Thanks for cleaning this up!

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
-- 
Mike Kravetz
