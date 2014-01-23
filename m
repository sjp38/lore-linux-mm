Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f52.google.com (mail-bk0-f52.google.com [209.85.214.52])
	by kanga.kvack.org (Postfix) with ESMTP id 318FF6B0035
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 00:59:11 -0500 (EST)
Received: by mail-bk0-f52.google.com with SMTP id e11so189258bkh.25
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 21:59:10 -0800 (PST)
Received: from mail-la0-x22a.google.com (mail-la0-x22a.google.com [2a00:1450:4010:c03::22a])
        by mx.google.com with ESMTPS id aq8si8912758bkc.329.2014.01.22.21.59.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 21:59:09 -0800 (PST)
Received: by mail-la0-f42.google.com with SMTP id hr13so1122868lab.29
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 21:59:09 -0800 (PST)
Date: Thu, 23 Jan 2014 09:59:06 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [Bug 67651] Bisected: Lots of fragmented mmaps cause gimp to
 fail in 3.12 after exceeding vm_max_map_count
Message-ID: <20140123055906.GS1574@moon>
References: <20140122190816.GB4963@suse.de>
 <52E04A21.3050101@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52E04A21.3050101@mit.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Mel Gorman <mgorman@suse.de>, Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, gnome@rvzt.net, drawoc@darkrefraction.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org

On Wed, Jan 22, 2014 at 02:45:53PM -0800, Andy Lutomirski wrote:
> >     
> >     Thus when user space application track memory changes now it can detect if
> >     vma area is renewed.
> 
> Presumably some path is failing to set VM_SOFTDIRTY, thus preventing mms
> from being merged.
> 
> That being said, this could cause vma blowups for programs that are
> actually using this thing.

Hi Andy, indeed, this could happen. The easiest way is to ignore softdirty bit
when we're trying to merge vmas and set it one new merged. I think this should
be correct. Once I finish I'll send the patch.

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
