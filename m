Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 677386B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 13:51:28 -0500 (EST)
Received: by mail-qg0-f54.google.com with SMTP id t4so50706095qge.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 10:51:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g48si4754975qgd.15.2016.03.04.10.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 10:51:27 -0800 (PST)
Date: Fri, 4 Mar 2016 18:51:21 +0000
From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Message-ID: <20160304185120.GB2588@work-vm>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160303174615.GF2115@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E03770E33@SHSMSX101.ccr.corp.intel.com>
 <20160304081411.GD9100@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0377160A@SHSMSX101.ccr.corp.intel.com>
 <20160304102346.GB2479@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0414516C@shsmsx102.ccr.corp.intel.com>
 <56D9B6C2.3070708@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56D9B6C2.3070708@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: "Li, Liang Z" <liang.z.li@intel.com>, Roman Kagan <rkagan@virtuozzo.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>

* Paolo Bonzini (pbonzini@redhat.com) wrote:
> 
> 
> On 04/03/2016 15:26, Li, Liang Z wrote:
> >> > 
> >> > The memory usage will keep increasing due to ever growing caches, etc, so
> >> > you'll be left with very little free memory fairly soon.
> >> > 
> > I don't think so.
> > 
> 
> Roman is right.  For example, here I am looking at a 64 GB (physical)
> machine which was booted about 30 minutes ago, and which is running
> disk-heavy workloads (installing VMs).
> 
> Since I have started writing this email (2 minutes?), the amount of free
> memory has already gone down from 37 GB to 33 GB.  I expect that by the
> time I have finished running the workload, in two hours, it will not
> have any free memory.

But what about a VM sitting idle, or that just has more RAM assigned to it
than is currently using.
 I've got a host here that's been up for 46 days and has been doing some
heavy VM debugging a few days ago, but today:

# free -m
              total        used        free      shared  buff/cache   available
Mem:          96536        1146       44834         184       50555       94735

I very rarely use all it's RAM, so it's got a big chunk of free RAM, and yes
it's got a big chunk of cache as well.

Dave

> 
> Paolo
--
Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
