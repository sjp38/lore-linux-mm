Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 762E56B007E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 08:27:40 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id a64so79088801oii.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 05:27:40 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id g80si5861379pfk.4.2016.06.16.05.27.39
        for <linux-mm@kvack.org>;
        Thu, 16 Jun 2016 05:27:39 -0700 (PDT)
Date: Thu, 16 Jun 2016 15:27:35 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 1/2] Revert "mm: make faultaround produce old ptes"
Message-ID: <20160616122735.GB108167@black.fi.intel.com>
References: <1465893750-44080-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1465893750-44080-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20160616122001.GJ6836@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160616122001.GJ6836@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, "Huang, Ying" <ying.huang@intel.com>, Minchan Kim <minchan@kernel.org>, Vinayak Menon <vinmenon@codeaurora.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 16, 2016 at 02:20:02PM +0200, Michal Hocko wrote:
> On Tue 14-06-16 11:42:29, Kirill A. Shutemov wrote:
> > This reverts commit 5c0a85fad949212b3e059692deecdeed74ae7ec7.
> > 
> > The commit causes ~6% regression in unixbench.
> 
> Is the regression fully explained? My understanding from the email
> thread is that this is suspiciously too high. It is not like I would
> be against the revert but having an explanation would be really
> appreciated.

My understanding is that it's overhead on setting accessed bit:

http://lkml.kernel.org/r/20160613125248.GA30109@black.fi.intel.com

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
