Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 525DD9003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 11:08:30 -0400 (EDT)
Received: by oihq81 with SMTP id q81so126339978oih.2
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 08:08:30 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id w186si19078981oia.86.2015.07.21.08.08.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 08:08:29 -0700 (PDT)
Message-ID: <1437491241.3214.211.camel@hp.com>
Subject: Re: [PATCH RESEND 2/3] mm, x86: Remove region_is_ram() call from
 ioremap
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 21 Jul 2015 09:07:21 -0600
In-Reply-To: <alpine.DEB.2.11.1507211620250.18576@nanos>
References: <1437088996-28511-1-git-send-email-toshi.kani@hp.com>
	 <1437088996-28511-3-git-send-email-toshi.kani@hp.com>
	 <alpine.DEB.2.11.1507211620250.18576@nanos>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, travis@sgi.com, roland@purestorage.com, dan.j.williams@intel.com, mcgrof@suse.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>

On Tue, 2015-07-21 at 16:31 +0200, Thomas Gleixner wrote:
> On Thu, 16 Jul 2015, Toshi Kani wrote:
> > Note, removing the call to region_is_ram() is also necessary to
> > fix bugs in region_is_ram().  walk_system_ram_range() requires
> > RAM ranges be page-aligned in the iomem_resource table to work
> > properly.  This restriction has allowed multiple ioremaps to RAM
> > (setup_data) which are page-unaligned.  Using fixed region_is_ram()
> > will cause these callers to start failing.
> 
> Which callers? 

They are the callers I noticed.

 - Multiple ioremap calls from arch/x86/kernel/kdebugfs.c.
 - Multiple ioremap calls from arch/x86/kernel/ksysfs.c.
 - pcibios_add_device()

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
