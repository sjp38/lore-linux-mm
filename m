Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1DBB36B004F
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 08:35:41 -0400 (EDT)
Date: Wed, 10 Jun 2009 14:36:43 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v5
Message-ID: <20090610123643.GA22161@wotan.suse.de>
References: <20090603846.816684333@firstfloor.org> <20090603184648.2E2131D028F@basil.firstfloor.org> <20090609100922.GF14820@wotan.suse.de> <Pine.LNX.4.64.0906091637430.13213@sister.anvils> <20090610083803.GE6597@localhost> <20090610085939.GE31155@wotan.suse.de> <20090610092010.GA32584@localhost> <20090610110305.GB3876@wotan.suse.de> <20090610121645.GC5657@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090610121645.GC5657@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 10, 2009 at 08:16:45PM +0800, Wu Fengguang wrote:
> On Wed, Jun 10, 2009 at 07:03:05PM +0800, Nick Piggin wrote:
> > The application equally may not need to touch the data again, so
> > killing it might cause some inconsistency in whatever it is currently
> > doing.
> 
> Yes, early kill can also be evil. What I can do now is to document the
> early kill parameter more carefully.

That would be good. I would also strongly consider removing
options if possible to make things simpler and if there
is not a really compelling reason to have it.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
