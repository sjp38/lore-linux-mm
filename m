Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7346B0005
	for <linux-mm@kvack.org>; Wed, 23 May 2018 17:35:55 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l85-v6so13623070pfb.18
        for <linux-mm@kvack.org>; Wed, 23 May 2018 14:35:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m79-v6si19291398pfi.236.2018.05.23.14.35.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 May 2018 14:35:54 -0700 (PDT)
Date: Wed, 23 May 2018 23:35:51 +0200
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH v3 0/2] mm: PAGE_KERNEL_* fallbacks
Message-ID: <20180523213551.GF4511@wotan.suse.de>
References: <20180510185507.2439-1-mcgrof@kernel.org>
 <20180516164403.GI27853@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180516164403.GI27853@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: arnd@arndb.de, willy@infradead.org, geert@linux-m68k.org, linux-m68k@lists.linux-m68k.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mcgrof@kernel.org

On Wed, May 16, 2018 at 06:44:03PM +0200, Luis R. Rodriguez wrote:
> On Thu, May 10, 2018 at 11:55:05AM -0700, Luis R. Rodriguez wrote:
> > This is the 3rd iteration for moving PAGE_KERNEL_* fallback
> > definitions into asm-generic headers. Greg asked for a Changelog
> > for patch iteration changes, its below.
> > 
> > All these patches have been tested by 0-day.
> > 
> > Questions, and specially flames are greatly appreciated.
> 
> *Poke*

Greg, since this does touch the firmware loader as well, *poke*.

  Luis
