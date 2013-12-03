Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1EF6B008A
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 18:54:56 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b15so1777072eek.10
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 15:54:55 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id s42si4699927eew.98.2013.12.03.15.54.55
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 15:54:55 -0800 (PST)
Date: Tue, 3 Dec 2013 23:54:52 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 04/15] mm: numa: Serialise parallel get_user_page against
 THP migration
Message-ID: <20131203235452.GT11295@suse.de>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de>
 <1386060721-3794-5-git-send-email-mgorman@suse.de>
 <529E6447.4030304@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <529E6447.4030304@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Dec 03, 2013 at 06:07:51PM -0500, Rik van Riel wrote:
> On 12/03/2013 03:51 AM, Mel Gorman wrote:
> 
> > +
> > +	if (page_count(page) != 2) {
> > +		set_pmd_at(mm, mmun_start, pmd, orig_entry);
> > +		flush_tlb_range(vma, mmun_start, mmun_end);
> 
> The mmun_start and mmun_end variables are introduced in patch 5.
> 

Thanks, fixed now.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
