Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f46.google.com (mail-qe0-f46.google.com [209.85.128.46])
	by kanga.kvack.org (Postfix) with ESMTP id D69436B00B4
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 11:00:25 -0500 (EST)
Received: by mail-qe0-f46.google.com with SMTP id a11so2862693qen.5
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 08:00:25 -0800 (PST)
Received: from b232-35.smtp-out.amazonses.com (b232-35.smtp-out.amazonses.com. [199.127.232.35])
        by mx.google.com with ESMTP id 2si3778593qcp.80.2013.12.09.08.00.24
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 08:00:25 -0800 (PST)
Date: Mon, 9 Dec 2013 16:00:24 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 14/15] mm: fix TLB flush race between migration, and
 change_protection_range
In-Reply-To: <52A29278.9000609@redhat.com>
Message-ID: <00000142d816866f-615798f8-74d8-401c-b35a-88aa1dbc8eb5-000000@email.amazonses.com>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de> <1386060721-3794-15-git-send-email-mgorman@suse.de> <529E641A.7040804@redhat.com> <20131203234637.GS11295@suse.de> <529F3D51.1090203@redhat.com> <20131204160741.GC11295@suse.de>
 <20131206141331.10880d2b@annuminas.surriel.com> <00000142c99cf5b0-69cc9987-aa36-4889-af6a-1a45032d0d13-000000@email.amazonses.com> <52A23FD1.3040102@redhat.com> <00000142ca7218fe-a5566a24-0ef5-4545-8a98-d33116b7d703-000000@email.amazonses.com>
 <52A29278.9000609@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 6 Dec 2013, Rik van Riel wrote:

> > Ok then what are you trying to fix?
>
> It would help if you had actually read the patch.

I read the patch. Please update the documentation to accurately describe
the race.

>From what I can see this race affects only huge pages and the basic issue
seems to be that huge pages do not use migration entries but directly
replace the pmd (migrate_misplaced_transhuge_page() f.e.).

That is not safe and there may be multiple other races as we add more
general functionality to huge pages. An intermediate stage is needed
that allows the clearing out of remote tlb entries before the new tlb
entry becomes visible.

Then you wont need this code anymore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
