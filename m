Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 75D6F6B0035
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 01:06:12 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so1418034pbb.20
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 22:06:12 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id i8si12663466pav.161.2014.01.22.22.06.10
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 22:06:11 -0800 (PST)
Date: Wed, 22 Jan 2014 22:09:10 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 67651] Bisected: Lots of fragmented mmaps cause gimp to
 fail in 3.12 after exceeding vm_max_map_count
Message-Id: <20140122220910.198121ee.akpm@linux-foundation.org>
In-Reply-To: <20140123055906.GS1574@moon>
References: <20140122190816.GB4963@suse.de>
	<52E04A21.3050101@mit.edu>
	<20140123055906.GS1574@moon>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Mel Gorman <mgorman@suse.de>, Pavel Emelyanov <xemul@parallels.com>, gnome@rvzt.net, drawoc@darkrefraction.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org

On Thu, 23 Jan 2014 09:59:06 +0400 Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> On Wed, Jan 22, 2014 at 02:45:53PM -0800, Andy Lutomirski wrote:
> > >     
> > >     Thus when user space application track memory changes now it can detect if
> > >     vma area is renewed.
> > 
> > Presumably some path is failing to set VM_SOFTDIRTY, thus preventing mms
> > from being merged.
> > 
> > That being said, this could cause vma blowups for programs that are
> > actually using this thing.
> 
> Hi Andy, indeed, this could happen. The easiest way is to ignore softdirty bit
> when we're trying to merge vmas and set it one new merged. I think this should
> be correct. Once I finish I'll send the patch.

Hang on.  We think the problem is that gimp is generating vmas which
*should* be merged, but for unknown reasons they differ in
VM_SOFTDIRTY, yes?

Shouldn't we work out where we're forgetting to set VM_SOFTDIRTY? 
Putting bandaids over this error when we come to trying to merge the
vmas sounds very wrong?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
