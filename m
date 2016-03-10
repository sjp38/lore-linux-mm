Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id DD2036B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 02:30:21 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id y89so63563332qge.2
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 23:30:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n197si2473427qhc.23.2016.03.09.23.30.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 23:30:21 -0800 (PST)
Date: Thu, 10 Mar 2016 13:00:00 +0530
From: Amit Shah <amit.shah@redhat.com>
Subject: Re: [Qemu-devel] [RFC kernel 0/2]A PV solution for KVM live
 migration optimization
Message-ID: <20160310073000.GA4678@grmbl.mre>
References: <1457593292-30686-1-git-send-email-jitendra.kolhe@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1457593292-30686-1-git-send-email-jitendra.kolhe@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jitendra Kolhe <jitendra.kolhe@hpe.com>
Cc: liang.z.li@intel.com, dgilbert@redhat.com, ehabkost@redhat.com, kvm@vger.kernel.org, mst@redhat.com, quintela@redhat.com, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, linux-mm@kvack.org, pbonzini@redhat.com, akpm@linux-foundation.org, virtualization@lists.linux-foundation.org, rth@twiddle.net, mohan_parthasarathy@hpe.com, simhan@hpe.com

On (Thu) 10 Mar 2016 [12:31:32], Jitendra Kolhe wrote:
> On 3/8/2016 4:44 PM, Amit Shah wrote:
> >>>> Hi,
> >>>>   An interesting solution; I know a few different people have been looking at
> >>>> how to speed up ballooned VM migration.
> >>>>
> >>>
> >>> Ooh, different solutions for the same purpose, and both based on the balloon.
> >>
> >> We were also tying to address similar problem, without actually needing to modify
> >> the guest driver. Please find patch details under mail with subject.
> >> migration: skip sending ram pages released by virtio-balloon driver
> >
> > The scope of this patch series seems to be wider: don't send free
> > pages to a dest at all, vs. don't send pages that are ballooned out.
> 
> Hi,
> 
> Thanks for your response. The scope of this patch series doesna??t seem to take care 
> of ballooned out pages. To balloon out a guest ram page the guest balloon driver does 
> a alloc_page() and then return the guest pfn to Qemu, so ballooned out pages will not 
> be seen as free ram pages by the guest.
> Thus we will still end up scanning (for zero page) for ballooned out pages during 
> migration. It would be ideal if we could have both solutions.

Yes, of course it would be nice to have both solutions.  My response was to the line:

> >>> Ooh, different solutions for the same purpose, and both based on the balloon.

which sounded misleading to me for a couple of reasons: 1, as you
describe, pages being considered by this patchset and yours are
different; and 2, as I mentioned in the other mail, this patchset
doesn't really depend on the balloon, and I believe it should not.


		Amit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
