Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 812916B0069
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 11:12:44 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d199so115277wmd.0
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 08:12:44 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id t2si4127514wmb.23.2016.10.21.08.12.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Oct 2016 08:12:43 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id d128so21686wmf.0
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 08:12:43 -0700 (PDT)
Date: Fri, 21 Oct 2016 17:12:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] shmem: avoid huge pages for small files
Message-ID: <20161021151241.GP6045@dhcp22.suse.cz>
References: <20161017145539.GA26930@node.shutemov.name>
 <20161018142007.GL12092@dhcp22.suse.cz>
 <20161018143207.GA5833@node.shutemov.name>
 <20161018183023.GC27792@dhcp22.suse.cz>
 <alpine.LSU.2.11.1610191101250.10318@eggly.anvils>
 <20161020103946.GA3881@node.shutemov.name>
 <20161020224630.GO23194@dastard>
 <20161021020116.GD1075@tassilo.jf.intel.com>
 <20161021050118.GR23194@dastard>
 <20161021150007.GA13597@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161021150007.GA13597@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Chinner <david@fromorbit.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 21-10-16 18:00:07, Kirill A. Shutemov wrote:
> On Fri, Oct 21, 2016 at 04:01:18PM +1100, Dave Chinner wrote:
[...]
> > None of these aspects can be optimised sanely by a single threshold,
> > especially when considering the combination of access patterns vs file
> > layout.
> 
> I agree.
> 
> Here I tried to address the particular performance regression I see with
> huge pages enabled on tmpfs. It doesn't mean to fix all possible issues.

So can we start simple and use huge pages on shmem mappings only when
they are larger than the huge page? Without any tunable which might turn
out to be misleading/wrong later on. If I understand Dave's comments it
is really not all that clear that a mount option makes sense. I cannot
comment on those but they clearly show that there are multiple points of
view here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
