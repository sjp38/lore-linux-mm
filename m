Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 16C5E6B02E1
	for <linux-mm@kvack.org>; Fri, 12 May 2017 12:57:11 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u21so52406244pgn.5
        for <linux-mm@kvack.org>; Fri, 12 May 2017 09:57:11 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id 1si3890910pgq.372.2017.05.12.09.57.10
        for <linux-mm@kvack.org>;
        Fri, 12 May 2017 09:57:10 -0700 (PDT)
Date: Fri, 12 May 2017 12:57:08 -0400 (EDT)
Message-Id: <20170512.125708.475573831936972365.davem@davemloft.net>
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
From: David Miller <davem@davemloft.net>
In-Reply-To: <65b8a658-76d1-0617-ece8-ff7a3c1c4046@oracle.com>
References: <ab667486-54a0-a36e-6797-b5f7b83c10f7@oracle.com>
	<9088ad7e-8b3b-8eba-2fdf-7b0e36e4582e@oracle.com>
	<65b8a658-76d1-0617-ece8-ff7a3c1c4046@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pasha.tatashin@oracle.com
Cc: mhocko@kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com

From: Pasha Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 11 May 2017 16:59:33 -0400

> We should either keep memset() only for deferred struct pages as what
> I have in my patches.
> 
> Another option is to add a new function struct_page_clear() which
> would default to memset() and to something else on platforms that
> decide to optimize it.
> 
> On SPARC it would call STBIs, and we would do one membar call after
> all "struct pages" are initialized.

No membars will be performed for single individual page struct clear,
the cutoff to use the STBI is larger than that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
