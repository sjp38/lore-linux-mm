Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9B60A6B0003
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 02:41:38 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id p187so53469267wmp.0
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 23:41:38 -0800 (PST)
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com. [195.75.94.103])
        by mx.google.com with ESMTPS id y125si37015wmd.48.2015.12.17.23.41.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Dec 2015 23:41:37 -0800 (PST)
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Fri, 18 Dec 2015 07:41:36 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 2F8D31B08072
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 07:42:07 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tBI7fXQD63700998
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 07:41:34 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tBI7fX28022737
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 00:41:33 -0700
Date: Fri, 18 Dec 2015 08:41:32 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] mm/swapfile: mm/swapfile: fix swapoff vs. software
 dirty bits
Message-ID: <20151218084132.7661051e@mschwide>
In-Reply-To: <CAM5jBj5vOTjbt1f3Z6P=qQymX5-_W6bLGVQ1Q9FERx6tpKbthQ@mail.gmail.com>
References: <1442222687-9758-1-git-send-email-schwidefsky@de.ibm.com>
	<1442222687-9758-2-git-send-email-schwidefsky@de.ibm.com>
	<CAM5jBj5vOTjbt1f3Z6P=qQymX5-_W6bLGVQ1Q9FERx6tpKbthQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, 17 Dec 2015 19:08:46 +0300
Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> On Mon, Sep 14, 2015 at 12:24 PM, Martin Schwidefsky
> <schwidefsky@de.ibm.com> wrote:
> > Fixes a regression introduced with commit 179ef71cbc085252
> > "mm: save soft-dirty bits on swapped pages"
> >
> > The maybe_same_pte() function is used to match a swap pte independent
> > of the swap software dirty bit set with pte_swp_mksoft_dirty().
> >
> > For CONFIG_HAVE_ARCH_SOFT_DIRTY=y but CONFIG_MEM_SOFT_DIRTY=n the
> > software dirty bit may be set but maybe_same_pte() will not recognize
> > a software dirty swap pte. Due to this a 'swapoff -a' will hang.
> >
> > The straightforward solution is to replace CONFIG_MEM_SOFT_DIRTY
> > with HAVE_ARCH_SOFT_DIRTY in maybe_same_pte().
> >
> > Cc: linux-mm@kvack.org
> > Cc: Cyrill Gorcunov <gorcunov@gmail.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Michal Hocko <mhocko@suse.cz>
> > Reported-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
> > Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> 
> We've been discussing this already
> http://comments.gmane.org/gmane.linux.kernel.mm/138664
 
Yes indeed. I'm still trying to find out how this mail has been
sent a second time. That was not intentional, sorry for the noise.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
