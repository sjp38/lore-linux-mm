Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id l774S8k9006069
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 21:28:08 -0700
Received: from an-out-0708.google.com (anac36.prod.google.com [10.100.54.36])
	by zps76.corp.google.com with ESMTP id l774S2rQ018377
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 21:28:04 -0700
Received: by an-out-0708.google.com with SMTP id c36so284556ana
        for <linux-mm@kvack.org>; Mon, 06 Aug 2007 21:28:02 -0700 (PDT)
Message-ID: <b040c32a0708062128r42d6a067l3a0c8c3818660e13@mail.gmail.com>
Date: Mon, 6 Aug 2007 21:28:01 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: + hugetlb-allow-extending-ftruncate-on-hugetlbfs.patch added to -mm tree
In-Reply-To: <20070807041559.GH13522@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200708061830.l76IUA6j008338@imap1.linux-foundation.org>
	 <20070807041559.GH13522@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: akpm@linux-foundation.org, agl@us.ibm.com, nacc@us.ibm.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/6/07, David Gibson <david@gibson.dropbear.id.au> wrote:
> Ken, is this quite sufficient?  At least if we're expanding a
> MAP_SHARED hugepage mapping, we should pre-reserve hugepages on an
> expanding ftruncate().

why do we need to reserve them?  mmap segments aren't extended, e.g.
vma length remains the same.  We only expand file size.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
