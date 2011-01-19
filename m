Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9F5BB8D003A
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 15:01:14 -0500 (EST)
Date: Wed, 19 Jan 2011 21:01:06 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [BUG] BUG: unable to handle kernel paging request at fffba000
Message-ID: <20110119200106.GL9506@random.random>
References: <20110119124047.GA30274@kwango.lan.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110119124047.GA30274@kwango.lan.net>
Sender: owner-linux-mm@kvack.org
To: Ilya Dryomov <idryomov@gmail.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello,

thanks for the report!

On Wed, Jan 19, 2011 at 02:40:47PM +0200, Ilya Dryomov wrote:
> Hello,
> 
> I just built a fresh 38-rc1 kernel with transparent huge page support
> built-in (TRANSPARENT_HUGEPAGE=y) and it failed to boot with the
> following bug.  However after the reboot everything went fine.  It turns
> out it only happens when fsck checks one or more filesystems before they
> are mounted.
> 
> It's easily reproducable it with touch /forcefsck and reboot on one of
> my 32-bit machines.  Haven't tried it on others yet.

Could you send me the vmlinux (or bzImage)? I can't see where it crash
otherwise.

Most certainly it's 32bit bug only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
