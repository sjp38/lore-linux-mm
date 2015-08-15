Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 062A26B0038
	for <linux-mm@kvack.org>; Sat, 15 Aug 2015 03:38:17 -0400 (EDT)
Received: by qkcs67 with SMTP id s67so32592407qkc.1
        for <linux-mm@kvack.org>; Sat, 15 Aug 2015 00:38:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 62si14207205qht.63.2015.08.15.00.38.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Aug 2015 00:38:16 -0700 (PDT)
Date: Sat, 15 Aug 2015 00:38:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memblock: validate the creation of debugfs files
Message-Id: <20150815003830.c87afaff.akpm@linux-foundation.org>
In-Reply-To: <20150815072636.GA2539@localhost>
References: <1439579011-14918-1-git-send-email-kuleshovmail@gmail.com>
	<20150814141944.4172fee6c9d7ae02a6258c80@linux-foundation.org>
	<20150815072636.GA2539@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Kuleshov <kuleshovmail@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Baoquan He <bhe@redhat.com>, Tang Chen <tangchen@cn.fujitsu.com>, Robin Holt <holt@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Sat, 15 Aug 2015 13:26:36 +0600 Alexander Kuleshov <kuleshovmail@gmail.com> wrote:

> Hello Andrew,
> 
> On 08-14-15, Andrew Morton wrote:
> > On Sat, 15 Aug 2015 01:03:31 +0600 Alexander Kuleshov <kuleshovmail@gmail.com> wrote:
> > 
> > > Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
> > 
> > There's no changelog.
> 
> Yes, will add it if there will be sense in the patch.
> 
> > 
> > Why?  Ignoring the debugfs API return values is standard practice.
> > 
> 
> Yes, but I saw many places where this practice is applicable (for example
> in the kernel/kprobes and etc.), besides this, the memblock API is used
> mostly at early stage, so we will have some output if something going wrong.

The debugfs error-handling rules are something Greg cooked up after one
too many beers.  I've never understood them, but maybe I continue to
miss the point.

Yes, I agree that if memblock's debugfs_create_file() fails, we want to
know about it because something needs fixing.  But that's true of
all(?) debugfs_create_file callsites, so it's a bit silly to add
warnings to them all.  Why not put the warning into
debugfs_create_file() itself?  And add a debugfs_create_file_no_warn()
if there are callsites which have reason to go it alone.  Or add a
debugfs_create_file_warn() wrapper.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
