Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C43836B000C
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 10:17:57 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id x81so2961643pgx.21
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 07:17:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h70si3883658pfc.269.2018.03.15.07.17.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Mar 2018 07:17:54 -0700 (PDT)
Date: Thu, 15 Mar 2018 07:17:49 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 00/16] remove eight obsolete architectures
Message-ID: <20180315141749.GA27100@infradead.org>
References: <20180314143529.1456168-1-arnd@arndb.de>
 <2929.1521106970@warthog.procyon.org.uk>
 <6c9d075c-d7a8-72a5-9b2d-af1feaa06c6c@suse.de>
 <CAK8P3a01pfvsdM1mR8raU9dA7p4H-jRJz2Y8-+KEY76W_Mukpg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK8P3a01pfvsdM1mR8raU9dA7p4H-jRJz2Y8-+KEY76W_Mukpg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Hannes Reinecke <hare@suse.de>, David Howells <dhowells@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, linux-block <linux-block@vger.kernel.org>, IDE-ML <linux-ide@vger.kernel.org>, "open list:HID CORE LAYER" <linux-input@vger.kernel.org>, Networking <netdev@vger.kernel.org>, linux-wireless <linux-wireless@vger.kernel.org>, linux-pwm@vger.kernel.org, linux-rtc@vger.kernel.org, linux-spi <linux-spi@vger.kernel.org>, linux-usb@vger.kernel.org, dri-devel <dri-devel@lists.freedesktop.org>, linux-fbdev@vger.kernel.org, linux-watchdog@vger.kernel.org, Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu, Mar 15, 2018 at 11:42:25AM +0100, Arnd Bergmann wrote:
> Is anyone producing a chip that includes enough of the Privileged ISA spec
> to have things like system calls, but not the MMU parts?

Various SiFive SOCs seem to support M and U mode, but no S mode or
iommu.  That should be enough for nommu Linux running in M mode if
someone cares enough to actually port it.
