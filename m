Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3841E6B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 17:55:54 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o124so38441664qke.9
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 14:55:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k31si3866973qte.266.2017.08.17.14.55.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 14:55:53 -0700 (PDT)
Date: Thu, 17 Aug 2017 17:55:50 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM-v25 00/19] HMM (Heterogeneous Memory Management) v25
Message-ID: <20170817215549.GD2872@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
 <20170817143916.63fca76e4c1fd841e0afd4cf@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170817143916.63fca76e4c1fd841e0afd4cf@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>

On Thu, Aug 17, 2017 at 02:39:16PM -0700, Andrew Morton wrote:
> On Wed, 16 Aug 2017 20:05:29 -0400 J__r__me Glisse <jglisse@redhat.com> wrote:
> 
> > Heterogeneous Memory Management (HMM) (description and justification)
> 
> The patchset adds 55 kbytes to x86_64's mm/*.o and there doesn't appear
> to be any way of avoiding this overhead, or of avoiding whatever
> runtime overheads are added.

HMM have already been integrated in couple of Red Hat kernel and AFAIK there
is no runtime performance issue reported. Thought the RHEL version does not
use static key as Dan asked.

> 
> It also adds 18k to arm's mm/*.o and arm doesn't support HMM at all.
> 
> So that's all quite a lot of bloat for systems which get no benefit from
> the patchset.  What can we do to improve this situation (a lot)?

I will look into why object file grow so much on arm. My guess is that the
new migrate code is the bulk of that. I can hide the new page migration code
behind a kernel configuration flag.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
