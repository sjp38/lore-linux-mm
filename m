Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7714F280250
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 04:29:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e6so20112890pfk.5
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 01:29:57 -0700 (PDT)
Received: from mail-pf0-f194.google.com (mail-pf0-f194.google.com. [209.85.192.194])
        by mx.google.com with ESMTPS id n66si7634424pfi.285.2016.10.07.01.29.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Oct 2016 01:29:56 -0700 (PDT)
Received: by mail-pf0-f194.google.com with SMTP id i85so2506726pfa.0
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 01:29:56 -0700 (PDT)
Date: Fri, 7 Oct 2016 10:29:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4 1/2] mm, proc: Fix region lost in /proc/self/smaps
Message-ID: <20161007082952.GI18439@dhcp22.suse.cz>
References: <1475296958-27652-1-git-send-email-robert.hu@intel.com>
 <20161003115210.GA26768@dhcp22.suse.cz>
 <1475806642.6073.10.camel@vmm.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475806642.6073.10.camel@vmm.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.hu@intel.com
Cc: pbonzini@redhat.com, akpm@linux-foundation.org, oleg@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, guangrong.xiao@linux.intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com

On Fri 07-10-16 10:17:22, Robert Hu wrote:
> On Mon, 2016-10-03 at 13:52 +0200, Michal Hocko wrote:
> > On Sat 01-10-16 12:42:37, Robert Ho wrote:
> > > Recently, Redhat reported that nvml test suite failed on QEMU/KVM,
> > > more detailed info please refer to:
> > >    https://bugzilla.redhat.com/show_bug.cgi?id=1365721
> > > 
> [trim...]
> > > 
> > > In order to fix this bug, we make 'file->version' indicate the end address
> > > of current VMA
> > 
> > I guess you wanted to finish that sentence, right?
> > "
> > m_start will then look up a vma which with vma_start < last_vm_end and
> > moves on to the next vma if we found the same or an overlapping vma.
> > This will guarantee that we will not miss an exclusive vma but we can
> > still miss one if the previous vma was shrunk. This is acceptable
> > because guaranteeing "never miss a vma" is simply not feasible. User has
> > to cope with some inconsistencies if the file is not read in one go.
> > "
> 
> Yes, you're right. Sorry that I didn't complement that in v4.
> I see the patch is already moved to -mm tree (by you?) with the above
> complemented. So I'm not supposed to work a v5 patch, am I right?

Andrew took the patch and updated the changelog. So there doesn't seem
to be any reason for v5 just for to update changelog. Unless you want to
have a different wording of course.

[...]
> > I am not sure how the two above are helpful as the patch has been
> > reworked basically.
> > 
> I might be wrong, I thought the change log should honestly write each
> version's changes, although it indeed looks confusing if looks at this
> single version only.
> 
> So I learned from you now that change log shall only reflect the final
> adopted changes only, right?

well, I would keep the changelog if it was helpful - aka small changes
along the way between different submissions - but it is much less useful
when the solution changes completely or way to much. Reader would have
a very limited context to understand those changes without reading the
original email threads anyway.

Anyway, thanks for your persistence!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
