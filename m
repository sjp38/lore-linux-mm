Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EA2C66B0487
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 17:27:20 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f188so270946746pgc.1
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 14:27:20 -0800 (PST)
Received: from mail-pg0-x22c.google.com (mail-pg0-x22c.google.com. [2607:f8b0:400e:c05::22c])
        by mx.google.com with ESMTPS id f192si10103499pfa.60.2016.11.18.14.27.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 14:27:20 -0800 (PST)
Received: by mail-pg0-x22c.google.com with SMTP id 3so107247849pgd.0
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 14:27:20 -0800 (PST)
Date: Fri, 18 Nov 2016 14:27:12 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 (re-send)] xen/gntdev: Use mempolicy instead of VM_IO
 flag to avoid NUMA balancing
In-Reply-To: <2bf041f3-8918-3c6f-8afb-c9edcc03dcd9@oracle.com>
Message-ID: <alpine.LSU.2.11.1611181421470.10145@eggly.anvils>
References: <1479413404-27332-1-git-send-email-boris.ostrovsky@oracle.com> <alpine.LSU.2.11.1611181335560.9605@eggly.anvils> <2bf041f3-8918-3c6f-8afb-c9edcc03dcd9@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, david.vrabel@citrix.com, jgross@suse.com, xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, olaf@aepfle.de

On Fri, 18 Nov 2016, Boris Ostrovsky wrote:
> On 11/18/2016 04:51 PM, Hugh Dickins wrote:
> > Hmm, sorry, but this seems overcomplicated to me: ingenious, but an
> > unusual use of the ->get_policy method, which is a little worrying,
> > since it has only been used for shmem (+ shm and kernfs) until now.
> >
> > Maybe I'm wrong, but wouldn't substituting VM_MIXEDMAP for VM_IO
> > solve the problem more simply?
> 
> It would indeed. I didn't want to use it because it has specific meaning
> ("Can contain "struct page" and pure PFN pages") and that didn't seem
> like the right flag to describe this vma.

It is okay if it contains 0 pure PFN pages; and no worse than VM_IO was.
A comment on why VM_MIXEDMAP is being used there would certainly be good.
But I do find its use preferable to enlisting an unusual ->get_policy.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
