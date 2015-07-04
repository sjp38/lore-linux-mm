Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9BB34280291
	for <linux-mm@kvack.org>; Sat,  4 Jul 2015 16:48:45 -0400 (EDT)
Received: by qgef3 with SMTP id f3so7582389qge.0
        for <linux-mm@kvack.org>; Sat, 04 Jul 2015 13:48:45 -0700 (PDT)
Received: from relay6-d.mail.gandi.net (relay6-d.mail.gandi.net. [2001:4b98:c:538::198])
        by mx.google.com with ESMTPS id k85si15286249qhc.46.2015.07.04.13.48.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 04 Jul 2015 13:48:44 -0700 (PDT)
Date: Sat, 4 Jul 2015 13:48:38 -0700
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: include/linux/bug.h:93:12: error: dereferencing pointer to
 incomplete type
Message-ID: <20150704204836.GA2565@x>
References: <201507042000.Xg8x65h2%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201507042000.Xg8x65h2%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, Jul 04, 2015 at 08:36:05PM +0800, kbuild test robot wrote:
> Hi Josh,
> 
> FYI, the error/warning still remains. You may either fix it or ask me to silently ignore in future.

As mentioned before, it's a bug in mn10300, not a bug in the commit in
question.  It needs fixing by the mn10300 architecture folks.  Please
send it to them in the future.

My description of the bug from the previous time this came up:
> This looks like a bug in mn10300.  This code is within an ifdef on
> CONFIG_GENERIC_BUG, and the declaration of the structure is within
> ifdefs on both CONFIG_GENERIC_BUG and CONFIG_BUG, but:
>
> > CONFIG_MN10300=y
> [...]
> > CONFIG_GENERIC_BUG=y
> [...]
> > # CONFIG_BUG is not set
>
> Other architectures, including x86 (arch/x86/Kconfig) and powerpc
> (arch/powerpc/Kconfig) have GENERIC_BUG depend on BUG.  Looks like
> mn10300 doesn't.

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
