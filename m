Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f49.google.com (mail-lf0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id BF9E76B0254
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 16:19:20 -0500 (EST)
Received: by lffu14 with SMTP id u14so17273673lff.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 13:19:20 -0800 (PST)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id q194si10935076lfe.30.2015.11.09.13.19.19
        for <linux-mm@kvack.org>;
        Mon, 09 Nov 2015 13:19:19 -0800 (PST)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH] tree wide: Use kvfree() than conditional kfree()/vfree()
Date: Mon, 09 Nov 2015 22:48:37 +0100
Message-ID: <5253459.IxnqkcU2vL@vostro.rjw.lan>
In-Reply-To: <1447070170-8512-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1447070170-8512-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>, linux-acpi@vger.kernel.org, drbd-user@lists.linbit.com, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, codalist@coda.cs.cmu.edu, linux-mtd@lists.infradead.org, Jan Kara <jack@suse.com>, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Boris Petkov <bp@suse.de>

On Monday, November 09, 2015 08:56:10 PM Tetsuo Handa wrote:
> There are many locations that do
> 
>   if (memory_was_allocated_by_vmalloc)
>     vfree(ptr);
>   else
>     kfree(ptr);
> 
> but kvfree() can handle both kmalloc()ed memory and vmalloc()ed memory
> using is_vmalloc_addr(). Unless callers have special reasons, we can
> replace this branch with kvfree(). Please check and reply if you found
> problems.

ACK for the ACPI changes (and CCing Tony and Boris for the heads-up as they
are way more famailiar with the APEI code than I am).

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
