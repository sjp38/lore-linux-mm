Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AEEED6B0038
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 13:25:22 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 128so58325870pfz.1
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 10:25:22 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id ae6si2906254pad.277.2016.10.21.10.25.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 21 Oct 2016 10:25:21 -0700 (PDT)
Subject: Re: [RESEND PATCH v3 kernel 0/7] Extend virtio-balloon for fast
 (de)inflating & fast live migration
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <580A4F81.60201@intel.com>
Date: Fri, 21 Oct 2016 10:25:21 -0700
MIME-Version: 1.0
In-Reply-To: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>, mst@redhat.com
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, pbonzini@redhat.com, cornelia.huck@de.ibm.com, amit.shah@redhat.com

On 10/20/2016 11:24 PM, Liang Li wrote:
> Dave Hansen suggested a new scheme to encode the data structure,
> because of additional complexity, it's not implemented in v3.

So, what do you want done with this patch set?  Do you want it applied
as-is so that we can introduce a new host/guest ABI that we must support
until the end of time?  Then, we go back in a year or two and add the
newer format that addresses the deficiencies that this ABI has with a
third version?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
