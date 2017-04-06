Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7936A6B0397
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 14:33:29 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id b74so20195653iod.12
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 11:33:29 -0700 (PDT)
Received: from mail-io0-x232.google.com (mail-io0-x232.google.com. [2607:f8b0:4001:c06::232])
        by mx.google.com with ESMTPS id 77si2656145iom.97.2017.04.06.11.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 11:33:28 -0700 (PDT)
Received: by mail-io0-x232.google.com with SMTP id t68so1851532iof.0
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 11:33:28 -0700 (PDT)
Date: Thu, 6 Apr 2017 11:33:20 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: RE: ksmd lockup - kernel 4.11-rc series
In-Reply-To: <000801d2aede$cc414cd0$64c3e670$@net>
Message-ID: <alpine.LSU.2.11.1704061127090.17094@eggly.anvils>
References: <003401d2a750$19f98190$4dec84b0$@net> <20170327233617.353obb3m4wz7n5kv@node.shutemov.name> <alpine.LSU.2.11.1703280008020.2599@eggly.anvils> upRmczQN0LrIFupSgckp7c <000801d2aede$cc414cd0$64c3e670$@net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Doug Smythies <dsmythies@telus.net>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org

On Thu, 6 Apr 2017, Doug Smythies wrote:
> Hi,
> 
> Thank you for your quick work on this.
> 
> On 2017.04.02 17:03 Hugh Dickins wrote:
> > On Tue, 28 Mar 2017, Hugh Dickins wrote:
> >> On Tue, 28 Mar 2017, Kirill A. Shutemov wrote:
> >>> On Mon, Mar 27, 2017 at 04:16:00PM -0700, Doug Smythies wrote:
> 
> ...[snip]...
> 
> > Worked out what it was yesterday, but my first patch failed overnight:
> > I'd missed the placement of the next_pte label.  It had a similar fix
> > to mm/migrate.c in it, that hit me too in testing; but this morning I
> > find Naoya's 4b0ece6fa016 in git, which fixes that.
> 
> I think I got that one sometimes also.
> 
> >  Same issue here.
> >
> > [PATCH] mm: fix page_vma_mapped_walk() for ksm pages
> 
> ... [snip] ...
> 
> To establish a baseline, I ran kernel 4.11-rc5 without this
> patch for 24 hours. The failure occurred twice.
> 
> I have been running the exact same scenario with the patch
> for 55 hours now without any issues.

Great, thanks a lot for your careful testing and report.

> 
> Note: I stayed with version 1 of the patch, even though there
> was a version 2 sent out on Monday.

Right, I'd have done the same once useful testing was under way:
that's fine, the fix is the same, but version 2 looks more elegant.

I guess Andrew can add
Tested-by: Doug Smythies <dsmythies@telus.net>
or replace the Reported-by tag by
Reported-and-Tested-by: Doug Smythies <dsmythies@telus.net>
I'm not sure which is in fashion at present.

Thanks!
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
