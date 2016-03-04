Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id AA3D76B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 04:47:17 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id w104so39118653qge.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 01:47:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p199si2912752qhb.90.2016.03.04.01.47.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 01:47:16 -0800 (PST)
Date: Fri, 4 Mar 2016 11:47:09 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Message-ID: <20160304114519-mutt-send-email-mst@redhat.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160303174615.GF2115@work-vm>
 <20160304075538.GC9100@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E037714DA@SHSMSX101.ccr.corp.intel.com>
 <20160304083550.GE9100@rkaganb.sw.ru>
 <20160304090820.GA2149@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E03771639@SHSMSX101.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E03771639@SHSMSX101.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Roman Kagan <rkagan@virtuozzo.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>

On Fri, Mar 04, 2016 at 09:12:12AM +0000, Li, Liang Z wrote:
> > Although I wonder which is cheaper; that would be fairly expensive for the
> > guest wouldn't it? And you'd somehow have to kick the guest before
> > migration to do the ballooning - and how long would you wait for it to finish?
> 
> About 5 seconds for an 8G guest, balloon to 1G. Get the free pages bitmap take about 20ms
> for an 8G idle guest.
> 
> Liang

Where is the time spent though? allocating within guest?
Or passing the info to host?
If the former, we can use existing inflate/deflate vqs:
Have guest put each free page on inflate vq, then on deflate vq.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
