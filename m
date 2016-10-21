Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9AB026B0069
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 15:44:40 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id p53so108069208qtp.1
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 12:44:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 16si2947606qkd.95.2016.10.21.12.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Oct 2016 12:44:39 -0700 (PDT)
Date: Fri, 21 Oct 2016 22:44:37 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RESEND PATCH v3 kernel 0/7] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Message-ID: <20161021224428-mutt-send-email-mst@kernel.org>
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
 <580A4F81.60201@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <580A4F81.60201@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Liang Li <liang.z.li@intel.com>, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, pbonzini@redhat.com, cornelia.huck@de.ibm.com, amit.shah@redhat.com

On Fri, Oct 21, 2016 at 10:25:21AM -0700, Dave Hansen wrote:
> On 10/20/2016 11:24 PM, Liang Li wrote:
> > Dave Hansen suggested a new scheme to encode the data structure,
> > because of additional complexity, it's not implemented in v3.
> 
> So, what do you want done with this patch set?  Do you want it applied
> as-is so that we can introduce a new host/guest ABI that we must support
> until the end of time?  Then, we go back in a year or two and add the
> newer format that addresses the deficiencies that this ABI has with a
> third version?
> 

Exactly my questions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
