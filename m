Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8E26B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 09:40:41 -0400 (EDT)
Date: Wed, 8 Jul 2009 09:49:30 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][patch 4/4] fs: tmpfs, ext2 use new truncate
Message-ID: <20090708134930.GB26701@infradead.org>
References: <20090707144423.GC2714@wotan.suse.de> <20090707144918.GF2714@wotan.suse.de> <20090707163829.GB14947@infradead.org> <20090708065327.GM2714@wotan.suse.de> <20090708111420.GB20924@duck.suse.cz> <20090708122250.GP2714@wotan.suse.de> <20090708123244.GA22722@infradead.org> <20090708123904.GR2714@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090708123904.GR2714@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 08, 2009 at 02:39:04PM +0200, Nick Piggin wrote:
> Here is patch 4/4 after your parts folded in and other changes
> I said in last mail. (yes I do agree to split it up, but I'll
> just wait until we all agree on basics and then resend a new
> patchset).

Sure, that's fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
