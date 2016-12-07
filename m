Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA6ED6B0038
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 23:13:18 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j128so584264869pfg.4
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 20:13:18 -0800 (PST)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id u71si22273623pgd.117.2016.12.06.20.13.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 20:13:17 -0800 (PST)
Received: by mail-pf0-x22a.google.com with SMTP id 189so74562493pfz.3
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 20:13:17 -0800 (PST)
Date: Tue, 6 Dec 2016 20:13:07 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: make transparent hugepage size public
In-Reply-To: <db569a60-5dd1-b0a8-9fcb-6dd2106765ee@intel.com>
Message-ID: <alpine.LSU.2.11.1612061937220.1094@eggly.anvils>
References: <alpine.LSU.2.11.1612052200290.13021@eggly.anvils> <877f7difx1.fsf@linux.vnet.ibm.com> <85c787f4-36ff-37fe-ff93-e42bad4b7c1e@intel.com> <20161206171905.n7qwvfb5sjxn3iif@black.fi.intel.com> <db569a60-5dd1-b0a8-9fcb-6dd2106765ee@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org

On Tue, 6 Dec 2016, Dave Hansen wrote:
> On 12/06/2016 09:19 AM, Kirill A. Shutemov wrote:
> >>> > > We have in /proc/meminfo
> >>> > > 
> >>> > > Hugepagesize:       2048 kB
> >>> > > 
> >>> > > Does it makes it easy for application to find THP page size also there ?
> >> > 
> >> > Nope.  That's the default hugetlbfs page size.  Even on x86, that can be
> >> > changed and _could_ be 1G.  If hugetlbfs is configured out, you also
> >> > won't get this in meminfo.
> > I think Aneesh propose to add one more line into the file.
> 
> Ahhh, ok...
> 
> Personally, I think Hugh did the right things.  There's no reason to
> waste cycles sticking a number in meminfo that never changes.

Thanks, yes, that was my feeling: I prefer not to clutter /proc/meminfo
with constants - especially not a unit, or granularity, as this is
(too late to stop Hugepagesize of course, but I wish it weren't there,
and those HugePages_ numbers in kB).

On top of that, /proc/meminfo is the mm admin's "front page", whereas
this is a low-level detail: it somewhat goes against our claim of
"transparent" hugepages to post it up there, even though a few tests
etc may find the value useful: I'd rather bury it among the tunables.
(My guess is that Andrea felt rather the same, in choosing not to
publish it six years ago.)

But of course, that's just my/our opinion: any strong preferences?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
