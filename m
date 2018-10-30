Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA8AE6B02C4
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 13:05:11 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id r81-v6so11137446pfk.11
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 10:05:11 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w16-v6si24524936pge.9.2018.10.30.10.05.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 10:05:10 -0700 (PDT)
Date: Tue, 30 Oct 2018 18:05:43 +0100
From: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3 00/20] vmw_balloon: compaction, shrinker, 64-bit, etc.
Message-ID: <20181030170543.GA24012@kroah.com>
References: <20180926191336.101885-1-namit@vmware.com>
 <E1B69BF2-458D-435C-8065-6944111A9EC6@vmware.com>
 <20181030165119.GA23017@kroah.com>
 <0AC59738-06A0-43DC-8622-D4177FDDC1F3@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0AC59738-06A0-43DC-8622-D4177FDDC1F3@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Xavier Deguillard <xdeguillard@vmware.com>, LKML <linux-kernel@vger.kernel.org>, "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>

On Tue, Oct 30, 2018 at 04:52:55PM +0000, Nadav Amit wrote:
> From: gregkh@linuxfoundation.org
> Sent: October 30, 2018 at 4:51:19 PM GMT
> > To: Nadav Amit <namit@vmware.com>
> > Cc: Arnd Bergmann <arnd@arndb.de>, Xavier Deguillard <xdeguillard@vmware.com>, LKML <linux-kernel@vger.kernel.org>, Michael S. Tsirkin <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, linux-mm@kvack.org <linux-mm@kvack.org>, virtualization@lists.linux-foundation.org <virtualization@lists.linux-foundation.org>
> > Subject: Re: [PATCH v3 00/20] vmw_balloon: compaction, shrinker, 64-bit, etc.
> > 
> > 
> > On Tue, Oct 30, 2018 at 04:32:22PM +0000, Nadav Amit wrote:
> >> From: Nadav Amit
> >> Sent: September 26, 2018 at 7:13:16 PM GMT
> >>> To: Arnd Bergmann <arnd@arndb.de>, gregkh@linuxfoundation.org
> >>> Cc: Xavier Deguillard <xdeguillard@vmware.com>, linux-kernel@vger.kernel.org>, Nadav Amit <namit@vmware.com>, Michael S. Tsirkin <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, linux-mm@kvack.org>, virtualization@lists.linux-foundation.org
> >>> Subject: [PATCH v3 00/20] vmw_balloon: compaction, shrinker, 64-bit, etc.
> >>> 
> >>> 
> >>> This patch-set adds the following enhancements to the VMware balloon
> >>> driver:
> >>> 
> >>> 1. Balloon compaction support.
> >>> 2. Report the number of inflated/deflated ballooned pages through vmstat.
> >>> 3. Memory shrinker to avoid balloon over-inflation (and OOM).
> >>> 4. Support VMs with memory limit that is greater than 16TB.
> >>> 5. Faster and more aggressive inflation.
> >>> 
> >>> To support compaction we wish to use the existing infrastructure.
> >>> However, we need to make slight adaptions for it. We add a new list
> >>> interface to balloon-compaction, which is more generic and efficient,
> >>> since it does not require as many IRQ save/restore operations. We leave
> >>> the old interface that is used by the virtio balloon.
> >>> 
> >>> Big parts of this patch-set are cleanup and documentation. Patches 1-13
> >>> simplify the balloon code, document its behavior and allow the balloon
> >>> code to run concurrently. The support for concurrency is required for
> >>> compaction and the shrinker interface.
> >>> 
> >>> For documentation we use the kernel-doc format. We are aware that the
> >>> balloon interface is not public, but following the kernel-doc format may
> >>> be useful one day.
> >>> 
> >>> v2->v3: * Moving the balloon magic-number out of uapi (Greg)
> >>> 
> >>> v1->v2:	* Fix build error when THP is off (kbuild)
> >>> 	* Fix build error on i386 (kbuild)
> >> 
> >> Greg,
> >> 
> >> I realize you didna??t apply patches 17-20. Any reason for that?
> > 
> > I have no idea, that was a few thousand patches reviewed ago...
> > 
> > Did I not say anything about this when I applied them?
> > 
> > greg k-h
> 
> You regarded the magic-number in v2, which I fixed for v3.
> 
> Should I resend?

Please do, but note that I will not be reviewing anything until after
4.20-rc1 is out.

thanks,

greg k-h
