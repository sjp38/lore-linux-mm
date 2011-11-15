Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8645B6B006E
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 11:05:28 -0500 (EST)
Date: Tue, 15 Nov 2011 10:05:25 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [OOPS]: Kernel 3.1 (ext3?)
In-Reply-To: <20111114195352.GB17328@quack.suse.cz>
Message-ID: <alpine.DEB.2.00.1111151004050.22502@router.home>
References: <20111110132929.GA11417@zeus> <20111114195352.GB17328@quack.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Watts <akwatts@ymail.com>, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org

On Mon, 14 Nov 2011, Jan Kara wrote:

> On Thu 10-11-11 08:29:37, Andrew Watts wrote:
> > I had the following kernel panic today on 3.1 (machine was compiling code
> > unattended). It would appear to be a bug/regression introduced sometime
> > between 2.6.39.4 and 3.1.
>   Hmm, the report is missing a line (top one) saying why the kernel
> actually crashed. Can you add that?
>
>   Also it seems you are using SLUB allocator, right? This seems like a
> problem there so adding some CCs.

Likely some data corruption. Enable slub debugging by passing

slub_debug

on the kernel commandline please to get some information as to where and
when this happens.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
