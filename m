Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 941B86B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 11:08:56 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id f92so7543776qtb.4
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 08:08:56 -0700 (PDT)
Received: from mail-qk0-x232.google.com (mail-qk0-x232.google.com. [2607:f8b0:400d:c09::232])
        by mx.google.com with ESMTPS id p83si1513369qki.47.2017.06.22.08.08.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 08:08:55 -0700 (PDT)
Received: by mail-qk0-x232.google.com with SMTP id 16so14497776qkg.2
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 08:08:55 -0700 (PDT)
Date: Thu, 22 Jun 2017 11:08:49 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [RFC PATCH 0/4] Support for metadata specific accounting
Message-ID: <20170622150848.GA932@destiny>
References: <1498141404-18807-1-git-send-email-nborisov@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1498141404-18807-1-git-send-email-nborisov@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <nborisov@suse.com>
Cc: tj@kernel.org, jbacik@fb.com, jack@suse.cz, jeffm@suse.com, chandan@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, axboe@kernel.dk

On Thu, Jun 22, 2017 at 05:23:20PM +0300, Nikolay Borisov wrote:
> Hello, 
> 
> This series is a report of Josef's original posting [1]. I've included 
> fine-grained changelog in each patch with my changes. Basically, I've forward
> ported it to 4.12-rc6 and tried incorporating the feedback which was given to 
> every individual patch (I've included link with that information in each 
> individual patch). 
> 
> The main rationale of pushing this is to enable btrfs' subpage-blocksizes
> patches to eventually be merged.
> 
> This patchset depends on patches (in listed order) which have already
> been submitted [2] [3] [4]. But overall they don't hamper review. 
> 

Hello,

I haven't reposted these patches because they depend on the other work I'm
doing wrt slab shrinking.  We can't do the sub page blocksize stuff until those
patches are in, and then I have to re-evaluate this stuff to make sure it still
makes sense.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
