Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 55CE46B0006
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 13:13:49 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id e9so1016878ioj.18
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 10:13:49 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0032.hostedemail.com. [216.40.44.32])
        by mx.google.com with ESMTPS id k21si647975iti.146.2018.03.15.10.13.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 10:13:48 -0700 (PDT)
Message-ID: <1521134022.22221.38.camel@perches.com>
Subject: Re: rfc: remove print_vma_addr ? (was Re: [PATCH 00/16] remove
 eight obsolete architectures)
From: Joe Perches <joe@perches.com>
Date: Thu, 15 Mar 2018 10:13:42 -0700
In-Reply-To: <20180315170830.GA17574@bombadil.infradead.org>
References: <20180314143529.1456168-1-arnd@arndb.de>
	 <2929.1521106970@warthog.procyon.org.uk>
	 <CAMuHMdXcxuzCOnFCNm4NXDv-wfYJDO5GQpB_ECu7j=2BjMhNpA@mail.gmail.com>
	 <1521133006.22221.35.camel@perches.com>
	 <20180315170830.GA17574@bombadil.infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Linux-Arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, linux-block@vger.kernel.org, linux-ide@vger.kernel.org, linux-input@vger.kernel.org, netdev <netdev@vger.kernel.org>, linux-wireless <linux-wireless@vger.kernel.org>, Linux PWM List <linux-pwm@vger.kernel.org>, linux-rtc@vger.kernel.org, linux-spi <linux-spi@vger.kernel.org>, USB list <linux-usb@vger.kernel.org>, DRI Development <dri-devel@lists.freedesktop.org>, Linux Fbdev development list <linux-fbdev@vger.kernel.org>, Linux Watchdog Mailing List <linux-watchdog@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Thu, 2018-03-15 at 10:08 -0700, Matthew Wilcox wrote:
> On Thu, Mar 15, 2018 at 09:56:46AM -0700, Joe Perches wrote:
> > I have a patchset that creates a vsprintf extension for
> > print_vma_addr and removes all the uses similar to the
> > print_symbol() removal.
> > 
> > This now avoids any possible printk interleaving.
> > 
> > Unfortunately, without some #ifdef in vsprintf, which
> > I would like to avoid, it increases the nommu kernel
> > size by ~500 bytes.
> > 
> > Anyone think this is acceptable?
[]
> This doesn't feel like a huge win since it's only called ~once per
> architecture.  I'd be more excited if it made the printing of the whole
> thing standardised; eg we have a print_fault() function in mm/memory.c
> which takes a suitable set of arguments.

Sure but perhaps that's not feasible as the surrounding output
is per-arch specific.

What could be a standardized fault message here?
