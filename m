Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 083446B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 17:30:38 -0400 (EDT)
Received: by yhda23 with SMTP id a23so14640462yhd.2
        for <linux-mm@kvack.org>; Thu, 07 May 2015 14:30:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c79si1649269yha.200.2015.05.07.14.30.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 14:30:36 -0700 (PDT)
Date: Thu, 7 May 2015 14:30:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] mm/memblock: Allocate boot time data structures
 from mirrored memory
Message-Id: <20150507143034.250f8632c8179ba1950d6798@linux-foundation.org>
In-Reply-To: <CA+8MBbLh4xX2TWaNncJO3Snre7oXJoDpVV95rQhch7vE4=t2yg@mail.gmail.com>
References: <cover.1430772743.git.tony.luck@intel.com>
	<ec15446621a86b74ab1c7237c8c3e21b0b3e0e06.1430772743.git.tony.luck@intel.com>
	<20150506163016.a2d79f89abc7543cb80307ac@linux-foundation.org>
	<CA+8MBbLh4xX2TWaNncJO3Snre7oXJoDpVV95rQhch7vE4=t2yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 7 May 2015 14:24:46 -0700 Tony Luck <tony.luck@gmail.com> wrote:

> On Wed, May 6, 2015 at 4:30 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> >> +     if (!ret && flag) {
> >> +             pr_warn("Could not allocate %lld bytes of mirrored memory\n", size);
> >
> > This printk will warn on some configs.  Print a phys_addr_t with %pap.
> > I think.  See huge comment over lib/vsprintf.c:pointer().
> 
> The comment may be huge - but it seems to lie about phys_addr_t :-(
> 
> I changed to %pap and got:
> 
> mm/memblock.c: In function 'memblock_find_in_range':
> mm/memblock.c:276:3: warning: format '%p' expects argument of type
> 'void *', but argument 2 has type 'phys_addr_t' [-Wformat=]
>    pr_warn("Could not allocate %pap bytes of mirrored memory\n",

Use "&size" rather than "size".  All the %p extensions require a
pointer to the thing-to-be-printed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
