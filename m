Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6532B82F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 15:46:58 -0500 (EST)
Received: by wmec201 with SMTP id c201so28021153wme.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 12:46:57 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id v136si1057163wmd.15.2015.11.06.12.46.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 06 Nov 2015 12:46:57 -0800 (PST)
Date: Fri, 6 Nov 2015 20:46:41 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] arm: Use kernel mm when updating section permissions
Message-ID: <20151106204641.GT8644@n2100.arm.linux.org.uk>
References: <1446685239-28522-1-git-send-email-labbott@fedoraproject.org>
 <20151105094615.GP8644@n2100.arm.linux.org.uk>
 <563B81DA.2080409@redhat.com>
 <20151105162719.GQ8644@n2100.arm.linux.org.uk>
 <563BFCC4.8050705@redhat.com>
 <CAGXu5jLS8GPxmMQwd9qw+w+fkMqU-GYyME5WUuKZZ4qTesVzCQ@mail.gmail.com>
 <563CF510.9080506@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <563CF510.9080506@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@fedoraproject.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, Nov 06, 2015 at 10:44:32AM -0800, Laura Abbott wrote:
> with my test patch. I think setting both current->active_mm and &init_mm
> is sufficient. Maybe explicitly setting swapper_pg_dir would be cleaner?

Please, stop thinking like this.  If you're trying to change the kernel
section mappings after threads have been spawned, you need to change
them for _all_ threads, which means you need to change them for every
page table that's in existence at that time - you can't do just one
table and hope everyone updates, it doesn't work like that.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
