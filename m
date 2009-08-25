Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 66E096B00BB
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 05:23:02 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv4 0/2] vhost: a kernel-level virtio server
Date: Tue, 25 Aug 2009 18:15:41 +0930
References: <20090819150029.GA4236@redhat.com>
In-Reply-To: <20090819150029.GA4236@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200908251815.42707.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 20 Aug 2009 12:30:29 am Michael S. Tsirkin wrote:
> Rusty, could you review and comment on the patches please?  Since most
> of the code deals with virtio from host side, I think it will make sense
> to merge them through your tree. What do you think?

Yep, I've been waiting for all the other comments, then I got ill.

Now I'm all recovered, what better way to spend an evening than reviewing
fresh code?

New dir seems fine to me, too.

Thanks,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
