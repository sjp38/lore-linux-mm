Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 160DE6B0254
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 00:43:09 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id q63so26572011pfb.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 21:43:09 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id o90si10021879pfi.192.2016.02.24.21.43.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 21:43:08 -0800 (PST)
Received: by mail-pa0-x22c.google.com with SMTP id fl4so26072768pad.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 21:43:08 -0800 (PST)
Date: Wed, 24 Feb 2016 21:43:06 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Problems with swapping in v4.5-rc on POWER
In-Reply-To: <877fhttmr1.fsf@linux.vnet.ibm.com>
Message-ID: <alpine.LSU.2.11.1602242136270.6876@eggly.anvils>
References: <alpine.LSU.2.11.1602241716220.15121@eggly.anvils> <877fhttmr1.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Hugh Dickins <hughd@google.com>, Paul Mackerras <paulus@ozlabs.org>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu, 25 Feb 2016, Aneesh Kumar K.V wrote:
> 
> Can you test the impact of the merge listed below ?(ie, revert the merge and see if
> we can reproduce and also verify with merge applied). This will give us a
> set of commits to look closer. We had quiet a lot of page table
> related changes going in this merge window. 
> 
> f689b742f217b2ffe7 ("Pull powerpc updates from Michael Ellerman:")
> 
> That is the merge commit that added _PAGE_PTE. 

Another experiment running on it at the moment, I'd like to give that
a few more hours, and then will try the revert you suggest.  But does
that merge revert cleanly, did you try?  I'm afraid of interactions,
whether obvious or subtle, with the THP refcounting rework.  Oh, since
I don't have THP configured on, maybe I can ignore any issues from that.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
