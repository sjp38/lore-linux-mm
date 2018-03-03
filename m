Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9CE6B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 20:08:29 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id u46so6203746otg.16
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 17:08:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 205sor2888641oib.181.2018.03.02.17.08.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 17:08:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180302164052.5eea1b896e3a7125d1e1f23a@linux-foundation.org>
References: <1519908465-12328-1-git-send-email-neelx@redhat.com>
 <cover.1520011944.git.neelx@redhat.com> <0485727b2e82da7efbce5f6ba42524b429d0391a.1520011945.git.neelx@redhat.com>
 <20180302164052.5eea1b896e3a7125d1e1f23a@linux-foundation.org>
From: Daniel Vacek <neelx@redhat.com>
Date: Sat, 3 Mar 2018 02:08:27 +0100
Message-ID: <CACjP9X_tpVVDPUvyc-B2QU=2J5MXbuFsDcG90d7L0KuwEEuR-g@mail.gmail.com>
Subject: Re: [PATCH v3 2/2] mm/page_alloc: fix memmap_init_zone pageblock alignment
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Paul Burton <paul.burton@imgtec.com>, stable@vger.kernel.org

On Sat, Mar 3, 2018 at 1:40 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Sat,  3 Mar 2018 01:12:26 +0100 Daniel Vacek <neelx@redhat.com> wrote:
>
>> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
>> where possible") introduced a bug where move_freepages() triggers a
>> VM_BUG_ON() on uninitialized page structure due to pageblock alignment.
>
> b92df1de5d28 was merged a year ago.  Can you suggest why this hasn't
> been reported before now?

Yeah. I was surprised myself I couldn't find a fix to backport to
RHEL. But actually customers started to report this as soon as 7.4
(where b92df1de5d28 was merged in RHEL) was released. I remember
reports from September/October-ish times. It's not easily reproduced
and happens on a handful of machines only. I guess that's why. But
that does not make it less serious, I think.

Though there actually is a report here:
https://bugzilla.kernel.org/show_bug.cgi?id=196443

And there are reports for Fedora from July:
https://bugzilla.redhat.com/show_bug.cgi?id=1473242
and CentOS: https://bugs.centos.org/view.php?id=13964
and we internally track several dozens reports for RHEL bug
https://bugzilla.redhat.com/show_bug.cgi?id=1525121

Enough? ;-)

> This makes me wonder whether a -stable backport is really needed...

For some machines it definitely is. Won't hurt either, IMHO.

--nX

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
