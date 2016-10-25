Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4C5166B0253
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 23:52:17 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id n189so196726626qke.0
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:52:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 17si12284261qto.35.2016.10.24.20.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 20:52:16 -0700 (PDT)
Date: Tue, 25 Oct 2016 06:52:13 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RESEND PATCH v3 kernel 0/7] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Message-ID: <20161025065143-mutt-send-email-mst@kernel.org>
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
 <580A4F81.60201@intel.com>
 <20161021224428-mutt-send-email-mst@kernel.org>
 <F2CBF3009FA73547804AE4C663CAB28E3A0F9FA3@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E3A0F9FA3@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>

On Sun, Oct 23, 2016 at 11:29:25AM +0000, Li, Liang Z wrote:
> > On Fri, Oct 21, 2016 at 10:25:21AM -0700, Dave Hansen wrote:
> > > On 10/20/2016 11:24 PM, Liang Li wrote:
> > > > Dave Hansen suggested a new scheme to encode the data structure,
> > > > because of additional complexity, it's not implemented in v3.
> > >
> > > So, what do you want done with this patch set?  Do you want it applied
> > > as-is so that we can introduce a new host/guest ABI that we must
> > > support until the end of time?  Then, we go back in a year or two and
> > > add the newer format that addresses the deficiencies that this ABI has
> > > with a third version?
> > >
> > 
> > Exactly my questions.
> 
> Hi Dave & Michael,
> 
> In the V2, both of you thought that the memory I allocated for the bitmap is too large, and gave some
>  suggestions about the solution, so I changed the implementation and used  scattered pages for the bitmap
> instead of a large physical continued memory. I didn't get the comments about the changes, so I am not 
> sure whether that is OK or not, that's the why I resend the V3, I just want your opinions about that part. 
> 
> I will implement the new schema as Dave suggested in V4. Before that, could you take a look at this version and
> give some comments? 
> 
> Thanks!
> Liang

Sure, I'll try to review just that part.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
