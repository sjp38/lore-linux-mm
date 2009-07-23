Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7F5926B004D
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 22:35:19 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6N2ZJVk020445
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 23 Jul 2009 11:35:19 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E26F545DE60
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 11:35:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B6E2245DE7D
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 11:35:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 97EBB1DB803A
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 11:35:17 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D19C1DB8047
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 11:35:16 +0900 (JST)
Date: Thu, 23 Jul 2009 11:33:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC v17][PATCH 10/60] c/r: make file_pos_read/write() public
Message-Id: <20090723113320.65f6746d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1248256822-23416-11-git-send-email-orenl@librato.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
	<1248256822-23416-11-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@librato.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Alexey Dobriyan <adobriyan@gmail.com>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

a nitpick.

On Wed, 22 Jul 2009 05:59:32 -0400
Oren Laadan <orenl@librato.com> wrote:

> These two are used in the next patch when calling vfs_read/write()

> +static inline loff_t file_pos_read(struct file *file)
> +{
> +	return file->f_pos;
> +}
> +
> +static inline void file_pos_write(struct file *file, loff_t pos)
> +{
> +	file->f_pos = pos;
> +}
> +

I'm not sure but how about renaming this to
	file_pos() 
	set_file_pos()
at moving this to global include file ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
