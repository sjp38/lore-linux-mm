Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id A8FF76B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 12:04:51 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fl4so44161041pad.0
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 09:04:51 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id q90si13610841pfa.198.2016.03.09.09.04.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 09:04:50 -0800 (PST)
Date: Wed, 9 Mar 2016 20:04:39 +0300
From: Roman Kagan <rkagan@virtuozzo.com>
Subject: Re: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Message-ID: <20160309170438.GB9715@rkaganb.sw.ru>
References: <F2CBF3009FA73547804AE4C663CAB28E0377160A@SHSMSX101.ccr.corp.intel.com>
 <20160304102346.GB2479@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0414516C@shsmsx102.ccr.corp.intel.com>
 <20160304163246-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E041452EA@shsmsx102.ccr.corp.intel.com>
 <20160305214748-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04146308@shsmsx102.ccr.corp.intel.com>
 <20160307110852-mutt-send-email-mst@redhat.com>
 <20160309142851.GA9715@rkaganb.sw.ru>
 <20160309173017-mutt-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160309173017-mutt-send-email-mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "Li, Liang Z" <liang.z.li@intel.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>, riel@redhat.com

On Wed, Mar 09, 2016 at 05:41:39PM +0200, Michael S. Tsirkin wrote:
> On Wed, Mar 09, 2016 at 05:28:54PM +0300, Roman Kagan wrote:
> > For (1) I've been trying to make a point that skipping clean pages is
> > much more likely to result in noticable benefit than free pages only.
> 
> I guess when you say clean you mean zero?

No I meant clean, i.e. those that could be evicted from RAM without
causing I/O.

> Yea. In fact, one can zero out any number of pages
> quickly by putting them in balloon and immediately
> taking them out.
> 
> Access will fault a zero page in, then COW kicks in.

I must be missing something obvious, but how is that different from
inflating and then immediately deflating the balloon?

> We could have a new zero VQ (or some other option)
> to pass these pages guest to host, but this only
> works well if page size matches the host page size.

I'm afraid I don't yet understand what kind of pages that would be and
how they are different from ballooned pages.

I still tend to think that ballooning is a sensible solution to the
problem at hand; it's just the granularity that makes things slow and
stands in the way.

Roman.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
