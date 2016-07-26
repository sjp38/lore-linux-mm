Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 14ADD6B025F
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 16:59:54 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so33369678wme.1
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 13:59:54 -0700 (PDT)
Received: from outbound1.eu.mailhop.org (outbound1.eu.mailhop.org. [52.28.251.132])
        by mx.google.com with ESMTPS id w8si2694209wjh.5.2016.07.26.13.59.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 13:59:52 -0700 (PDT)
Date: Tue, 26 Jul 2016 20:59:44 +0000
From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH] [RFC] Introduce mmap randomization
Message-ID: <20160726205944.GM4541@io.lakedaemon.net>
References: <1469557346-5534-1-git-send-email-william.c.roberts@intel.com>
 <1469557346-5534-2-git-send-email-william.c.roberts@intel.com>
 <20160726200309.GJ4541@io.lakedaemon.net>
 <476DC76E7D1DF2438D32BFADF679FC560125F29C@ORSMSX103.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <476DC76E7D1DF2438D32BFADF679FC560125F29C@ORSMSX103.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Roberts, William C" <william.c.roberts@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "keescook@chromium.org" <keescook@chromium.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "nnk@google.com" <nnk@google.com>, "jeffv@google.com" <jeffv@google.com>, "salyzyn@android.com" <salyzyn@android.com>, "dcashman@android.com" <dcashman@android.com>

Hi William,

On Tue, Jul 26, 2016 at 08:13:23PM +0000, Roberts, William C wrote:
> > > From: Jason Cooper [mailto:jason@lakedaemon.net]
> > > On Tue, Jul 26, 2016 at 11:22:26AM -0700, william.c.roberts@intel.com wrote:
> > > > Performance Measurements:
> > > > Using strace with -T option and filtering for mmap on the program ls
> > > > shows a slowdown of approximate 3.7%
> > >
> > > I think it would be helpful to show the effect on the resulting object code.
> > 
> > Do you mean the maps of the process? I have some captures for whoopsie on my
> > Ubuntu system I can share.

No, I mean changes to mm/mmap.o.

> > One thing I didn't make clear in my commit message is why this is good. Right
> > now, if you know An address within in a process, you know all offsets done with
> > mmap(). For instance, an offset To libX can yield libY by adding/subtracting an
> > offset. This is meant to make rops a bit harder, or In general any mapping offset
> > mmore difficult to find/guess.

Are you able to quantify how many bits of entropy you're imposing on the
attacker?  Is this a chair in the hallway or a significant increase in
the chances of crashing the program before finding the desired address?

thx,

Jason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
