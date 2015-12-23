Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id E0A6E82F86
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 09:23:54 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l126so151999572wml.1
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 06:23:54 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id v18si44130557wju.157.2015.12.23.06.23.53
        for <linux-mm@kvack.org>;
        Wed, 23 Dec 2015 06:23:53 -0800 (PST)
Date: Wed, 23 Dec 2015 15:23:49 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 01/11] resource: Add System RAM resource type
Message-ID: <20151223142349.GG30213@pd.tnic>
References: <20151216122642.GE29775@pd.tnic>
 <1450280642.29051.76.camel@hpe.com>
 <20151216154916.GF29775@pd.tnic>
 <1450283759.20148.11.camel@hpe.com>
 <20151216174523.GH29775@pd.tnic>
 <CAPcyv4h+n51Z2hskP2+PX44OB47OQwrKcqVr3nrvMzG++qjC+w@mail.gmail.com>
 <20151216181712.GJ29775@pd.tnic>
 <1450302758.20148.75.camel@hpe.com>
 <20151222113422.GE3728@pd.tnic>
 <1450814672.10450.83.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1450814672.10450.83.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>

On Tue, Dec 22, 2015 at 01:04:32PM -0700, Toshi Kani wrote:
> The above example referred the case with distros, not with the upstream. 
>  That is, one writes a new loadable module and makes it available in the
> upstream.  Then s/he makes it work on a distro used by the customers, but
> may or may not be able to change the distro kernel/drivers used by the
> customers.

Huh?

Still sounds bogus to me. Distro kernels get stuff backported to them
all the time to accomodate new features, hw support.

Your new interfaces will be used only in new code so if distros want
it, they can either backport the new kernel interfaces or use an older
version with the strings.

> I agree that we can add new interfaces with the type check.  This 'type'
> may need some clarification since it is an assigned type, which is
> different from I/O resource type.  That is, "System RAM" is an I/O resource
> type (i.e. IORESOURCE_SYSTEM_RAM), but "Crash kernel" is an assigned type
> to a particular range of System RAM.  A range may be associated with
> multiple names, so as multiple assigned types.  For lack of a better idea,
> I may call it 'assign_type'.  I am open for a better name.

Or assigned_type or named_type or so...

I think we should avoid calling it "type" completely in order to avoid
confusion with the IORESOURCE_* types and call it "desc" or so to mean
description, sort, etc, because the name is also a description of the
resource to a certain degree...

> OK, I will try to convert the existing callers with the new interfaces.

Either that or add the new interfaces, use them in your use case, add
big fat comments explaining that people should use those from now on
when searching by name and add a check to checkpatch to catch future
mis-uses...

Thanks!

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
