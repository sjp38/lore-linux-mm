Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA2A6B0071
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 11:42:57 -0400 (EDT)
Received: by yhpn97 with SMTP id n97so41644232yhp.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 08:42:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n63si1353471yka.21.2015.06.08.08.42.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 08:42:56 -0700 (PDT)
Message-ID: <5575B7F6.6090000@redhat.com>
Date: Mon, 08 Jun 2015 11:42:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mmap.c: optimization of do_mmap_pgoff function
References: <1433584472-19151-1-git-send-email-kwapulinski.piotr@gmail.com>
In-Reply-To: <1433584472-19151-1-git-send-email-kwapulinski.piotr@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>, akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, mhocko@suse.cz, sasha.levin@oracle.com, dave@stgolabs.net, koct9i@gmail.com, pfeiner@google.com, dh.herrmann@gmail.com, vishnu.ps@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/06/2015 05:54 AM, Piotr Kwapulinski wrote:
> The simple check for zero length memory mapping may be performed
> earlier. It causes that in case of zero length memory mapping some
> unnecessary code is not executed at all. It does not make the code less
> readable and saves some CPU cycles.
> 
> Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
