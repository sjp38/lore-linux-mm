Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 215906B00B4
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 05:22:54 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Page allocation failures in guest
Date: Wed, 26 Aug 2009 11:47:17 +0930
References: <20090713115158.0a4892b0@mjolnir.ossman.eu> <200908121501.53167.rusty@rustcorp.com.au> <20090813222548.5e0743dd@mjolnir.ossman.eu>
In-Reply-To: <20090813222548.5e0743dd@mjolnir.ossman.eu>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200908261147.17838.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus-list@drzeus.cx>
Cc: Avi Kivity <avi@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 14 Aug 2009 05:55:48 am Pierre Ossman wrote:
> On Wed, 12 Aug 2009 15:01:52 +0930
> Rusty Russell <rusty@rustcorp.com.au> wrote:
> > Subject: virtio: net refill on out-of-memory
... 
> Patch applied. Now we wait. :)

Any results?

Thanks,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
