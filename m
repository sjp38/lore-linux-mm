Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF6D56B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 11:26:53 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id f185so36682796vkb.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 08:26:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k52si25354379qge.122.2016.04.19.08.26.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 08:26:53 -0700 (PDT)
Message-ID: <1461079592.3200.9.camel@redhat.com>
Subject: Re: [PATCH kernel 1/2] mm: add the related functions to build the
 free page bitmap
From: Rik van Riel <riel@redhat.com>
Date: Tue, 19 Apr 2016 11:26:32 -0400
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E04182594@shsmsx102.ccr.corp.intel.com>
References: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
	 <1461076474-3864-2-git-send-email-liang.z.li@intel.com>
	 <1461077659.3200.8.camel@redhat.com>
	 <F2CBF3009FA73547804AE4C663CAB28E04182594@shsmsx102.ccr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>, "mst@redhat.com" <mst@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "agraf@suse.de" <agraf@suse.de>, "borntraeger@de.ibm.com" <borntraeger@de.ibm.com>

On Tue, 2016-04-19 at 15:02 +0000, Li, Liang Z wrote:
> > 
> > On Tue, 2016-04-19 at 22:34 +0800, Liang Li wrote:
> > > 
> > > The free page bitmap will be sent to QEMU through virtio
> > > interface and
> > > used for live migration optimization.
> > > Drop the cache before building the free page bitmap can get more
> > > free
> > > pages. Whether dropping the cache is decided by user.
> > > 
> > How do you prevent the guest from using those recently-freed pages
> > for
> > something else, between when you build the bitmap and the live
> > migration
> > completes?
> Because the dirty page logging is enabled before building the bitmap,
> there is no need
> to prevent the guest from using the recently-freed pages ...

Fair enough.

It would be good to have that mentioned in the
changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
