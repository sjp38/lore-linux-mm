Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 487B56B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 04:30:25 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id 129so64619356pfw.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 01:30:25 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id w84si3663186pfi.103.2016.03.10.01.30.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 01:30:24 -0800 (PST)
Date: Thu, 10 Mar 2016 12:30:08 +0300
From: Roman Kagan <rkagan@virtuozzo.com>
Subject: Re: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Message-ID: <20160310093007.GA14065@rkaganb.sw.ru>
References: <F2CBF3009FA73547804AE4C663CAB28E0414516C@shsmsx102.ccr.corp.intel.com>
 <20160304163246-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E041452EA@shsmsx102.ccr.corp.intel.com>
 <20160305214748-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04146308@shsmsx102.ccr.corp.intel.com>
 <20160307110852-mutt-send-email-mst@redhat.com>
 <20160309142851.GA9715@rkaganb.sw.ru>
 <20160309173017-mutt-send-email-mst@redhat.com>
 <20160309170438.GB9715@rkaganb.sw.ru>
 <1457552332.17933.24.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1457552332.17933.24.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "Li, Liang Z" <liang.z.li@intel.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>

On Wed, Mar 09, 2016 at 02:38:52PM -0500, Rik van Riel wrote:
> On Wed, 2016-03-09 at 20:04 +0300, Roman Kagan wrote:
> > On Wed, Mar 09, 2016 at 05:41:39PM +0200, Michael S. Tsirkin wrote:
> > > On Wed, Mar 09, 2016 at 05:28:54PM +0300, Roman Kagan wrote:
> > > > For (1) I've been trying to make a point that skipping clean
> > > > pages is
> > > > much more likely to result in noticable benefit than free pages
> > > > only.
> > > 
> > > I guess when you say clean you mean zero?
> > 
> > No I meant clean, i.e. those that could be evicted from RAM without
> > causing I/O.
> > 
> 
> Programs in the guest may have that memory mmapped.
> This could include things like libraries and executables.
> 
> How do you deal with the guest page cache containing
> references to now non-existent memory?
> 
> How do you re-populate the memory on the destination
> host?

I guess the confusion is due to the context I stripped from the previous
messages...  Actually I've been talking about doing full-fledged balloon
inflation before the migration, so, when it's deflated the guest will
fault in that data from the filesystem as usual.

Roman.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
