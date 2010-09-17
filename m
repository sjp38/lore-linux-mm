Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4F16B0083
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 09:47:45 -0400 (EDT)
Message-ID: <4C937177.1090909@kernel.org>
Date: Fri, 17 Sep 2010 15:47:35 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [stable] breaks 2.6.32.21+
References: <1281261197-8816-1-git-send-email-shijie8@gmail.com> <4C5EA651.7080009@kernel.org> <20100916213603.GW6447@anguilla.noreply.org> <20100916231307.GB24617@kroah.com>
In-Reply-To: <20100916231307.GB24617@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: Peter Palfrader <peter@palfrader.org>, stable@kernel.org, Huang Shijie <shijie8@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 09/17/2010 01:13 AM, Greg KH wrote:
> Odd, someone just reported the same problem for .35-stable as well.
> 
> Tejun, what's going on here?

Please drop it.  The memory leak was introduced after 2.6.36-rc1.  I
got confused which commit was in which kernel.  I'll be more careful
with stable cc's.  Sorry about that.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
