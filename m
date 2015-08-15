Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id D50DA6B0038
	for <linux-mm@kvack.org>; Sat, 15 Aug 2015 03:49:14 -0400 (EDT)
Received: by lbcbn3 with SMTP id bn3so56548509lbc.2
        for <linux-mm@kvack.org>; Sat, 15 Aug 2015 00:49:14 -0700 (PDT)
Received: from mail-lb0-x22d.google.com (mail-lb0-x22d.google.com. [2a00:1450:4010:c04::22d])
        by mx.google.com with ESMTPS id ed15si7540252lbb.171.2015.08.15.00.49.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Aug 2015 00:49:13 -0700 (PDT)
Received: by lbbtg9 with SMTP id tg9so57228628lbb.1
        for <linux-mm@kvack.org>; Sat, 15 Aug 2015 00:49:12 -0700 (PDT)
Date: Sat, 15 Aug 2015 13:48:50 +0600
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: Re: [PATCH] mm/memblock: validate the creation of debugfs files
Message-ID: <20150815074850.GA2866@localhost>
References: <1439579011-14918-1-git-send-email-kuleshovmail@gmail.com>
 <20150814141944.4172fee6c9d7ae02a6258c80@linux-foundation.org>
 <20150815072636.GA2539@localhost>
 <20150815003830.c87afaff.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150815003830.c87afaff.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Baoquan He <bhe@redhat.com>, Tang Chen <tangchen@cn.fujitsu.com>, Robin Holt <holt@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 08-15-15, Andrew Morton wrote:
> Yes, I agree that if memblock's debugfs_create_file() fails, we want to
> know about it because something needs fixing.  But that's true of
> all(?) debugfs_create_file callsites, so it's a bit silly to add
> warnings to them all.  Why not put the warning into
> debugfs_create_file() itself?

Good idea, but there are already some debugfs_create_file calls with checks and
warning, if these checks failed. I don't know how many, but I saw it.
Double warning is not good too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
