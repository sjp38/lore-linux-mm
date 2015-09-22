Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id AADDC6B0038
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 03:35:56 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so178419302wic.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 00:35:56 -0700 (PDT)
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com. [195.75.94.106])
        by mx.google.com with ESMTPS id n5si22949155wia.1.2015.09.22.00.35.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 22 Sep 2015 00:35:55 -0700 (PDT)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 22 Sep 2015 08:35:54 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id DFD7F1B08072
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 08:37:35 +0100 (BST)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8M7Zqjp35782782
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 07:35:52 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8M7ZpuZ026879
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 01:35:51 -0600
Date: Tue, 22 Sep 2015 09:35:49 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 1/2] mm: add architecture primitives for software dirty
 bit clearing
Message-ID: <20150922093549.504a5fb3@mschwide>
In-Reply-To: <20150921194854.GD3181@uranus>
References: <1442848940-22108-1-git-send-email-schwidefsky@de.ibm.com>
	<1442848940-22108-2-git-send-email-schwidefsky@de.ibm.com>
	<20150921194854.GD3181@uranus>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org

On Mon, 21 Sep 2015 22:48:54 +0300
Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> On Mon, Sep 21, 2015 at 05:22:19PM +0200, Martin Schwidefsky wrote:
> > There are primitives to create and query the software dirty bits
> > in a pte or pmd. But the clearing of the software dirty bits is done
> > in common code with x86 specific page table functions.
> > 
> > Add the missing architecture primitives to clear the software dirty
> > bits to allow the feature to be used on non-x86 systems, e.g. the
> > s390 architecture.
> > 
> > Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> 
> Looks good to me. Thank you, Martin!
> (I cant ack s390 part 'casuse I simply not familiar
>  with the architecture).

Sure, the s390 patch just shows why the new arch functions are needed..

> Acked-by: Cyrill Gorcunov <gorcunov@openvz.org>

Thanks. I have added both patches to the features branch of linux-s390
for the 4.4 merge window.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
