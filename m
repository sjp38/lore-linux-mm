Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A87DD6B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 19:22:57 -0400 (EDT)
Date: Thu, 22 Jul 2010 00:22:46 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 0/2] mbcache fixes
Message-ID: <20100721232245.GB903@ZenIV.linux.org.uk>
References: <4C46D1C5.90200@gmail.com>
 <4C46FD67.8070808@redhat.com>
 <20100721202637.4CC213C539AA@imap.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100721202637.4CC213C539AA@imap.suse.de>
Sender: owner-linux-mm@kvack.org
To: Andreas Gruenbacher <agruen@suse.de>
Cc: Eric Sandeen <sandeen@redhat.com>, hch@infradead.org, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-janitors <kernel-janitors@vger.kernel.org>, Wang Sheng-Hui <crosslonelyover@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 21, 2010 at 07:57:20PM +0200, Andreas Gruenbacher wrote:
> Al,
> 
> here is an mbcache cleanup and then a fixed version of Shenghui's minor
> shrinker function fix.  The patches have survived functional testing
> here.
> 
> This seems slightly too much for kernel-janitors, so could you please
> take the patches?

Done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
