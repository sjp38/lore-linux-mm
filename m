Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C5D6A6B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 10:16:50 -0400 (EDT)
Message-ID: <4CAC84CF.3060902@kernel.org>
Date: Wed, 06 Oct 2010 17:16:47 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: OOM panics with zram
References: <1281374816-904-1-git-send-email-ngupta@vflare.org> <1284053081.7586.7910.camel@nimitz> <4CA8CE45.9040207@vflare.org> <20101005234300.GA14396@kroah.com> <4CABDF0E.3050400@vflare.org> <20101006023624.GA27685@kroah.com> <4CABFB6F.2070800@vflare.org> <AANLkTi=0bPudtyVzebvM0hZUB6DdDhjopB06FOww8hvt@mail.gmail.com> <20101006140343.GC19470@kroah.com>
In-Reply-To: <20101006140343.GC19470@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

  On 6.10.2010 17.03, Greg KH wrote:
> Oops, I need to update the MAINTAINERS file, the proper place for the
> staging tree is now in git, at
>
> git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-next-2.6.git
>
> which feeds directly into the linux-next tree.

Excellent! Nitin, can you develop and test zram against this tree?

             Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
