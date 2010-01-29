Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2A4626B0047
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 08:38:21 -0500 (EST)
Date: Fri, 29 Jan 2010 13:38:16 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: kernel error : 'find /proc/ -type f | xargs -n 1 head -c 10
	>/dev/null'
Message-ID: <20100129133816.GQ19799@ZenIV.linux.org.uk>
References: <201001212017.00160.toralf.foerster@gmx.de> <2375c9f91001272051x3d2e89r24133c42f52082ea@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2375c9f91001272051x3d2e89r24133c42f52082ea@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Am??rico Wang <xiyou.wangcong@gmail.com>
Cc: Toralf F??rster <toralf.foerster@gmx.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 28, 2010 at 12:51:02PM +0800, Am??rico Wang wrote:
> 2010/1/22 Toralf F??rster <toralf.foerster@gmx.de>:
> > I was inspired by http://article.gmane.org/gmane.linux.kernel/941115 .
> >
> > Running the command (se subject) as a normal user at a 2.6.32.4 kernel
> > gives this in /var/log/messages:
> >
> > 2010-01-21T20:11:39.171+01:00 n22 kernel: head: page allocation failure. order:9, mode:0xd0
> 
> 
> Hmm, it is suspecious that we need 2^9 pages for seq_file...

Something's using single_open() and obscene amounts of output; should
switch to real iterator...  Which file it is?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
