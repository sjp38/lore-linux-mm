Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 59F266B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 10:08:31 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id k16so50083621iok.5
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 07:08:31 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id b26si5730940iod.98.2016.10.12.07.08.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 07:08:30 -0700 (PDT)
Date: Wed, 12 Oct 2016 09:08:31 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 0/1] man/set_mempolicy.2,mbind.2: add MPOL_LOCAL NUMA
 memory policy documentation
In-Reply-To: <4d816fee-4690-2ed7-7faa-c437e67cfbf5@gmail.com>
Message-ID: <alpine.DEB.2.20.1610120906150.14274@east.gentwo.org>
References: <alpine.DEB.2.20.1610100854001.27158@east.gentwo.org> <20161010162310.2463-1-kwapulinski.piotr@gmail.com> <4d816fee-4690-2ed7-7faa-c437e67cfbf5@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>, kirill.shutemov@linux.intel.com, vbabka@suse.cz, rientjes@google.com, mhocko@kernel.org, mgorman@techsingularity.net, liangchen.linux@gmail.com, nzimmer@sgi.com, a.p.zijlstra@chello.nl, riel@redhat.com, lee.schermerhorn@hp.com, jmarchan@redhat.com, joe@perches.com, corbet@lwn.net, iamyooon@gmail.com, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-man@vger.kernel.org, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org

On Wed, 12 Oct 2016, Michael Kerrisk (man-pages) wrote:

> > +arguments must specify the empty set. If the "local node" is low
> > +on free memory the kernel will try to allocate memory from other
> > +nodes. The kernel will allocate memory from the "local node"
> > +whenever memory for this node is available. If the "local node"
> > +is not allowed by the process's current cpuset context the kernel
> > +will try to allocate memory from other nodes. The kernel will
> > +allocate memory from the "local node" whenever it becomes allowed
> > +by the process's current cpuset context. In contrast
> > +.B MPOL_DEFAULT
> > +reverts to the policy of the process which may have been set with
> > +.BR set_mempolicy (2).
> > +It may not be the "local allocation".
>
> What is the sense of "may not be" here? (And repeated below).
> Is the meaning "this could be something other than"?
> Presumably the answer is yes, in which case I'll clarify
> the wording there. Let me know.

Someone may have set for example a round robin policy with numactl
--interleave before starting the process? Then allocations will go through
all nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
