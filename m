Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 60BEA6B0038
	for <linux-mm@kvack.org>; Sat, 15 Aug 2015 03:52:30 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so32532425qkb.2
        for <linux-mm@kvack.org>; Sat, 15 Aug 2015 00:52:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p13si14290918qkh.54.2015.08.15.00.52.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Aug 2015 00:52:29 -0700 (PDT)
Date: Sat, 15 Aug 2015 00:52:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memblock: validate the creation of debugfs files
Message-Id: <20150815005243.aab83953.akpm@linux-foundation.org>
In-Reply-To: <20150815074850.GA2866@localhost>
References: <1439579011-14918-1-git-send-email-kuleshovmail@gmail.com>
	<20150814141944.4172fee6c9d7ae02a6258c80@linux-foundation.org>
	<20150815072636.GA2539@localhost>
	<20150815003830.c87afaff.akpm@linux-foundation.org>
	<20150815074850.GA2866@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Kuleshov <kuleshovmail@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Baoquan He <bhe@redhat.com>, Tang Chen <tangchen@cn.fujitsu.com>, Robin Holt <holt@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Sat, 15 Aug 2015 13:48:50 +0600 Alexander Kuleshov <kuleshovmail@gmail.com> wrote:

> On 08-15-15, Andrew Morton wrote:
> > Yes, I agree that if memblock's debugfs_create_file() fails, we want to
> > know about it because something needs fixing.  But that's true of
> > all(?) debugfs_create_file callsites, so it's a bit silly to add
> > warnings to them all.  Why not put the warning into
> > debugfs_create_file() itself?
> 
> Good idea, but there are already some debugfs_create_file calls with checks and
> warning, if these checks failed. I don't know how many, but I saw it.
> Double warning is not good too.

Please ponder the sentence you deleted.  "Or add a
debugfs_create_file_warn() wrapper".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
