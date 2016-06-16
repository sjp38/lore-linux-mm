Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id DD5CE6B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 11:10:52 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id g18so28619117lfg.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 08:10:52 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id gh2si5890182wjd.127.2016.06.16.08.10.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 08:10:51 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id k184so12189101wme.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 08:10:51 -0700 (PDT)
Date: Thu, 16 Jun 2016 17:10:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] Revert "mm: make faultaround produce old ptes"
Message-ID: <20160616151049.GM6836@dhcp22.suse.cz>
References: <1465893750-44080-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1465893750-44080-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20160616122001.GJ6836@dhcp22.suse.cz>
 <20160616122735.GB108167@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160616122735.GB108167@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, "Huang, Ying" <ying.huang@intel.com>, Minchan Kim <minchan@kernel.org>, Vinayak Menon <vinmenon@codeaurora.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 16-06-16 15:27:35, Kirill A. Shutemov wrote:
> On Thu, Jun 16, 2016 at 02:20:02PM +0200, Michal Hocko wrote:
> > On Tue 14-06-16 11:42:29, Kirill A. Shutemov wrote:
> > > This reverts commit 5c0a85fad949212b3e059692deecdeed74ae7ec7.
> > > 
> > > The commit causes ~6% regression in unixbench.
> > 
> > Is the regression fully explained? My understanding from the email
> > thread is that this is suspiciously too high. It is not like I would
> > be against the revert but having an explanation would be really
> > appreciated.
> 
> My understanding is that it's overhead on setting accessed bit:
> 
> http://lkml.kernel.org/r/20160613125248.GA30109@black.fi.intel.com

But those numbers cannot explain the regression completely AFAIU. It
smells like something else is going on. Anyway, as I've said I do not
have anything against the revert just more than "unixbench regresses"
would be nice.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
