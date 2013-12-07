Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f41.google.com (mail-qe0-f41.google.com [209.85.128.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7D9296B00AF
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 22:14:05 -0500 (EST)
Received: by mail-qe0-f41.google.com with SMTP id gh4so1252853qeb.0
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 19:14:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id gc1si310986qcb.68.2013.12.06.19.14.04
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 19:14:04 -0800 (PST)
Message-ID: <52A29278.9000609@redhat.com>
Date: Fri, 06 Dec 2013 22:14:00 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 14/15] mm: fix TLB flush race between migration, and change_protection_range
References: <1386060721-3794-1-git-send-email-mgorman@suse.de> <1386060721-3794-15-git-send-email-mgorman@suse.de> <529E641A.7040804@redhat.com> <20131203234637.GS11295@suse.de> <529F3D51.1090203@redhat.com> <20131204160741.GC11295@suse.de> <20131206141331.10880d2b@annuminas.surriel.com> <00000142c99cf5b0-69cc9987-aa36-4889-af6a-1a45032d0d13-000000@email.amazonses.com> <52A23FD1.3040102@redhat.com> <00000142ca7218fe-a5566a24-0ef5-4545-8a98-d33116b7d703-000000@email.amazonses.com>
In-Reply-To: <00000142ca7218fe-a5566a24-0ef5-4545-8a98-d33116b7d703-000000@email.amazonses.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@suse.de>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/06/2013 07:25 PM, Christoph Lameter wrote:
> On Fri, 6 Dec 2013, Rik van Riel wrote:
> 
>>> When you start migrating a page a special page migration entry is
>>> created that will trap all accesses to the page. You can safely flush when
>>> the migration entry is there. Only allow a new PTE/PMD to be put there
>>> *after* the tlb flush.
>>
>> A PROT_NONE or NUMA pte is just as effective as a migration pte.
>> The only problem is, the TLB flush was not always done...
> 
> Ok then what are you trying to fix?

It would help if you had actually read the patch.


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
