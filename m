Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id D01DA6B0262
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:48:08 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id v188so84890418wme.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 05:48:08 -0700 (PDT)
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com. [195.75.94.101])
        by mx.google.com with ESMTPS id v124si18260704wmg.0.2016.04.11.05.48.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 05:48:07 -0700 (PDT)
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Mon, 11 Apr 2016 13:48:06 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4290E1B0806E
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 13:48:22 +0100 (BST)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u3BClfMa3277246
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 12:47:41 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u3BClf8Q018128
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 06:47:41 -0600
Date: Mon, 11 Apr 2016 14:47:39 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH 13/19] s390: get rid of superfluous __GFP_REPEAT
Message-ID: <20160411124739.GB3976@osiris>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
 <1460372892-8157-14-git-send-email-mhocko@kernel.org>
 <20160411132837.3cba168f.cornelia.huck@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160411132837.3cba168f.cornelia.huck@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-arch@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Mon, Apr 11, 2016 at 01:28:37PM +0200, Cornelia Huck wrote:
> On Mon, 11 Apr 2016 13:08:06 +0200
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > __GFP_REPEAT has a rather weak semantic but since it has been introduced
> > around 2.6.12 it has been ignored for low order allocations.
> > 
> > arch_dup_task_struct uses __GFP_REPEAT for fpu_regs_size which is either
> > sizeof(__vector128) * __NUM_VXRS = 4069B resp.
> > sizeof(freg_t) * __NUM_FPRS = 1024B AFAICS. page_table_alloc then uses
> > the flag for a single page allocation. This means that this flag has
> > never been actually useful here because it has always been used only for
> > PAGE_ALLOC_COSTLY requests.
> > 
> > Cc: Christian Borntraeger <borntraeger@de.ibm.com>
> > Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
> 
> Let's cc: Martin/Heiko instead :)
> 
> > Cc: linux-arch@vger.kernel.org
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  arch/s390/kernel/process.c | 2 +-
> >  arch/s390/mm/pgalloc.c     | 2 +-
> >  2 files changed, 2 insertions(+), 2 deletions(-)

Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
