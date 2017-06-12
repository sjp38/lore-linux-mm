Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 093A96B02B4
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 10:10:15 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b74so36434728pfj.5
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 07:10:15 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 1si9472863pgv.218.2017.06.12.07.10.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 07:10:14 -0700 (PDT)
Subject: Re: [PATCH v11 4/6] mm: function to offer a page block on the free
 list
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
 <1497004901-30593-5-git-send-email-wei.w.wang@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b92af473-f00e-b956-ea97-eb4626601789@intel.com>
Date: Mon, 12 Jun 2017 07:10:12 -0700
MIME-Version: 1.0
In-Reply-To: <1497004901-30593-5-git-send-email-wei.w.wang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

Please stop cc'ing me on things also sent to closed mailing lists
(virtio-dev@lists.oasis-open.org).  I'm happy to review things on open
lists, but I'm not fond of the closed lists bouncing things at me.

On 06/09/2017 03:41 AM, Wei Wang wrote:
> Add a function to find a page block on the free list specified by the
> caller. Pages from the page block may be used immediately after the
> function returns. The caller is responsible for detecting or preventing
> the use of such pages.

This description doesn't tell me very much about what's going on here.
Neither does the comment.

"Pages from the page block may be used immediately after the
 function returns".

Used by who?  Does the "may" here mean that it is OK, or is it a warning
that the contents will be thrown away immediately?

The hypervisor is going to throw away the contents of these pages,
right?  As soon as the spinlock is released, someone can allocate a
page, and put good data in it.  What keeps the hypervisor from throwing
away good data?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
