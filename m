Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id D84F16B0032
	for <linux-mm@kvack.org>; Sat, 20 Dec 2014 11:41:10 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id et14so3162279pad.17
        for <linux-mm@kvack.org>; Sat, 20 Dec 2014 08:41:10 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id wr6si18523055pbc.82.2014.12.20.08.41.08
        for <linux-mm@kvack.org>;
        Sat, 20 Dec 2014 08:41:09 -0800 (PST)
Message-ID: <5495A698.4050707@linux.intel.com>
Date: Sat, 20 Dec 2014 08:40:56 -0800
From: Dave Hansen <dave.hansen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] proc: task_mmu: show page size in /proc/<pid>/numa_maps
References: <c97f30472ec5fe79cb8fa8be66cc3d8509777990.1419079617.git.aquini@redhat.com>
In-Reply-To: <c97f30472ec5fe79cb8fa8be66cc3d8509777990.1419079617.git.aquini@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, linux-mm@kvack.org

On 12/20/2014 05:54 AM, Rafael Aquini wrote:
> This patch introduces 'pagesize' line element to /proc/<pid>/numa_maps
> report file in order to help disambiguating the size of pages that are
> backing memory areas mapped by a task. When the VMA backing page size
> is observed different from kernel's default PAGE_SIZE, the new element 
> is printed out to complement report output. This is specially useful to
> help differentiating between HUGE and GIGANTIC page VMAs.

Heh, I completely forgot about this.  Thanks for picking it back up.

I sometimes wonder what 'numa_maps' purpose is any if we should have
_some_ kind of policy about what goes in there vs. smaps.  numa_maps
seems to be turning in to smaps, minus the \n. :)

But that isn't the case for this patch.  The "anon=50 dirty=50 N0=50"
output of numa_maps is wholly *useless* without either this patch or
some other mechanism to find out of hugetbfs memory is present.  I think
that needs to make it in to the description.

I'm fine with the code, though.  Feel free to add my acked-by.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
