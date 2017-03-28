Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 88B3C6B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 12:55:24 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p64so51630170wrb.18
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 09:55:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d7si4012404wmi.91.2017.03.28.09.55.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Mar 2017 09:55:23 -0700 (PDT)
Date: Tue, 28 Mar 2017 09:55:13 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH] mm,hugetlb: compute page_size_log properly
Message-ID: <20170328165513.GC27446@linux-80c1.suse>
References: <1488992761-9464-1-git-send-email-dave@stgolabs.net>
 <20170328165343.GB27446@linux-80c1.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170328165343.GB27446@linux-80c1.suse>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, ak@linux.intel.com, mtk.manpages@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com

Sorry, forgot to add Anshuman.

On Tue, 28 Mar 2017, Davidlohr Bueso wrote:

>Do we have any consensus here? Keeping SHM_HUGE_* is currently
>winning 2-1. If there are in fact users out there computing the
>value manually, then I am ok with keeping it and properly exporting
>it. Michal?
>
>Thanks,
>Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
