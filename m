Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 74E1A82F65
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 19:18:42 -0400 (EDT)
Received: by ioll68 with SMTP id l68so3722902iol.3
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 16:18:42 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ft2si15894726igb.25.2015.10.19.16.18.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 16:18:42 -0700 (PDT)
Date: Mon, 19 Oct 2015 16:18:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] hugetlbfs fallocate hole punch race with page
 faults
Message-Id: <20151019161840.63e6afaa73aceec23e351905@linux-foundation.org>
In-Reply-To: <1445033310-13155-1-git-send-email-mike.kravetz@oracle.com>
References: <1445033310-13155-1-git-send-email-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>

On Fri, 16 Oct 2015 15:08:27 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> The hugetlbfs fallocate hole punch code can race with page faults.  The
> result is that after a hole punch operation, pages may remain within the
> hole.  No other side effects of this race were observed.
> 
> In preparation for adding userfaultfd support to hugetlbfs, it is desirable
> to plug or significantly shrink this hole.  This patch set uses the same
> mechanism employed in shmem (see commit f00cdc6df7).
> 

"still buggy but not as bad as before" isn't what we strive for ;) What
would it take to fix this for real?  An exhaustive description of the
bug would be a good starting point, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
