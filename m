Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 33FC56B02FA
	for <linux-mm@kvack.org>; Wed, 31 May 2017 10:19:44 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g143so3131489wme.13
        for <linux-mm@kvack.org>; Wed, 31 May 2017 07:19:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p89si31135510wma.51.2017.05.31.07.19.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 May 2017 07:19:43 -0700 (PDT)
Date: Wed, 31 May 2017 16:19:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
Message-ID: <20170531141939.GP27783@dhcp22.suse.cz>
References: <20170524111800.GD14733@dhcp22.suse.cz>
 <20170524142735.GF3063@rapoport-lnx>
 <20170530074408.GA7969@dhcp22.suse.cz>
 <20170530101921.GA25738@rapoport-lnx>
 <20170530103930.GB7969@dhcp22.suse.cz>
 <20170530140456.GA8412@redhat.com>
 <20170530143941.GK7969@dhcp22.suse.cz>
 <20170530154326.GB8412@redhat.com>
 <20170531120822.GL27783@dhcp22.suse.cz>
 <8FA5E4C2-D289-4AF5-AA09-6C199E58F9A5@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8FA5E4C2-D289-4AF5-AA09-6C199E58F9A5@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoprt <rppt@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed 31-05-17 15:39:22, Mike Rapoprt wrote:
> 
> 
> On May 31, 2017 3:08:22 PM GMT+03:00, Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > From what Mike said a global disable THP for the whole process
> >while the post-copy is in progress is a better solution anyway.
> 
> For the CRIU usecase, disabling THP for a while and re-enabling
> it back will do the trick, provided VMAs flags are not affected,
> like in the patch you've sent.  Moreover, we may even get away with
> ioctl(UFFDIO_COPY) if it's overhead shows to be negligible.  Still,
> I believe that MADV_RESET_HUGEPAGE (or some better named) command has
> the value on its own.

I would prefer if we could go the prctl if possible and add a new
MADV_RESET_HUGEPAGE if there is really a usecase for it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
