Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 02F056B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 05:05:59 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id n186so37683110wmn.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 02:05:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n126si24404052wmf.19.2015.12.14.02.05.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 Dec 2015 02:05:57 -0800 (PST)
Date: Mon, 14 Dec 2015 11:05:56 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mm related crash
Message-ID: <20151214100556.GB4540@dhcp22.suse.cz>
References: <20151210154801.GA12007@lahna.fi.intel.com>
 <20151214092433.GA90449@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151214092433.GA90449@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mika Westerberg <mika.westerberg@intel.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Mon 14-12-15 11:24:33, Kirill A. Shutemov wrote:
> On Thu, Dec 10, 2015 at 05:48:01PM +0200, Mika Westerberg wrote:
> > Hi Kirill,
> > 
> > I got following crash on my desktop machine while building swift. It
> > reproduces pretty easily on 4.4-rc4.
> > 
> > Before it happens the ld process is killed by OOM killer. I attached the
> > whole dmesg.
> > 
> > [  254.740603] page:ffffea00111c31c0 count:2 mapcount:0 mapping:          (null) index:0x0
> > [  254.740636] flags: 0x5fff8000048028(uptodate|lru|swapcache|swapbacked)
> > [  254.740655] page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
> > [  254.740679] ------------[ cut here ]------------
> > [  254.740690] kernel BUG at mm/memcontrol.c:5270!
> 
> 
> Hm. I don't see how this can happen.

What a coincidence. I have just posted a similar report:
http://lkml.kernel.org/r/20151214100156.GA4540@dhcp22.suse.cz except I
have hit the VM_BUG_ON from a different path. My suspicion is that
somebody unlocks the page while we are waiting on the writeback.
I am trying to reproduce this now.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
