Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D800A6B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 10:35:48 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id d186so28555172lfg.7
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 07:35:48 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id h142si4943294lfh.254.2016.10.12.07.35.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 07:35:47 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id b75so7344840lfg.3
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 07:35:47 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <alpine.DEB.2.20.1610120906150.14274@east.gentwo.org>
References: <alpine.DEB.2.20.1610100854001.27158@east.gentwo.org>
 <20161010162310.2463-1-kwapulinski.piotr@gmail.com> <4d816fee-4690-2ed7-7faa-c437e67cfbf5@gmail.com>
 <alpine.DEB.2.20.1610120906150.14274@east.gentwo.org>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Wed, 12 Oct 2016 16:35:26 +0200
Message-ID: <CAKgNAkjLLLkyU1-H_ur802o=mNnpOC0XAb_3TPRSc-RuRNYZFg@mail.gmail.com>
Subject: Re: [PATCH v3 0/1] man/set_mempolicy.2,mbind.2: add MPOL_LOCAL NUMA
 memory policy documentation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, mhocko@kernel.org, mgorman@techsingularity.net, Liang Chen <liangchen.linux@gmail.com>, nzimmer@sgi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, jmarchan@redhat.com, Joe Perches <joe@perches.com>, Jonathan Corbet <corbet@lwn.net>, SeokHoon Yoon <iamyooon@gmail.com>, n-horiguchi@ah.jp.nec.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, linux-man <linux-man@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

Hi Christoph,

On 12 October 2016 at 16:08, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 12 Oct 2016, Michael Kerrisk (man-pages) wrote:
>
>> > +arguments must specify the empty set. If the "local node" is low
>> > +on free memory the kernel will try to allocate memory from other
>> > +nodes. The kernel will allocate memory from the "local node"
>> > +whenever memory for this node is available. If the "local node"
>> > +is not allowed by the process's current cpuset context the kernel
>> > +will try to allocate memory from other nodes. The kernel will
>> > +allocate memory from the "local node" whenever it becomes allowed
>> > +by the process's current cpuset context. In contrast
>> > +.B MPOL_DEFAULT
>> > +reverts to the policy of the process which may have been set with
>> > +.BR set_mempolicy (2).
>> > +It may not be the "local allocation".
>>
>> What is the sense of "may not be" here? (And repeated below).
>> Is the meaning "this could be something other than"?
>> Presumably the answer is yes, in which case I'll clarify
>> the wording there. Let me know.
>
> Someone may have set for example a round robin policy with numactl
> --interleave before starting the process? Then allocations will go through
> all nodes.

So the sense is then "this could be something other than", right?

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
