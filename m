Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 980B06B007B
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 02:07:47 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1Soq5Q-00081c-WA
	for linux-mm@kvack.org; Wed, 11 Jul 2012 08:07:45 +0200
Received: from 112.132.141.1 ([112.132.141.1])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 11 Jul 2012 08:07:44 +0200
Received: from xiyou.wangcong by 112.132.141.1 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 11 Jul 2012 08:07:44 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 1/3] tmpfs: revert SEEK_DATA and SEEK_HOLE
Date: Wed, 11 Jul 2012 06:07:32 +0000 (UTC)
Message-ID: <jtj574$tb7$2@dough.gmane.org>
References: <alpine.LSU.2.00.1207091533001.2051@eggly.anvils>
 <alpine.LSU.2.00.1207091535480.2051@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 09 Jul 2012 at 22:41 GMT, Hugh Dickins <hughd@google.com> wrote:
> Revert 4fb5ef089b28 ("tmpfs: support SEEK_DATA and SEEK_HOLE").
> I believe it's correct, and it's been nice to have from rc1 to rc6;
> but as the original commit said:
>
> I don't know who actually uses SEEK_DATA or SEEK_HOLE, and whether it
> would be of any use to them on tmpfs.  This code adds 92 lines and 752
> bytes on x86_64 - is that bloat or worthwhile?


I don't think 752 bytes matter much, especially for x86_64.

>
> Nobody asked for it, so I conclude that it's bloat: let's revert tmpfs
> to the dumb generic support for v3.5.  We can always reinstate it later
> if useful, and anyone needing it in a hurry can just get it out of git.
>

If you don't have burden to maintain it, I'd prefer to leave as it is,
I don't think 752-bytes is the reason we revert it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
