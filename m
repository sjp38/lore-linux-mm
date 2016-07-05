Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF5C6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 22:08:07 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u201so273516679oie.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 19:08:07 -0700 (PDT)
Received: from takane.zaitcev.us (takane.zaitcev.us. [96.126.117.152])
        by mx.google.com with ESMTP id n127si1098261oib.282.2016.07.04.19.08.06
        for <linux-mm@kvack.org>;
        Mon, 04 Jul 2016 19:08:06 -0700 (PDT)
Date: Mon, 4 Jul 2016 20:08:04 -0600
From: Pete Zaitcev <zaitcev@kotori.zaitcev.us>
Subject: Re: [patch] Allow user.* xattr in tmpfs
Message-ID: <20160704200804.4c54ceb9@lembas.zaitcev.lan>
In-Reply-To: <alpine.LSU.2.11.1607041614360.25599@eggly.anvils>
References: <20160630223608.6ecbec55@lembas.zaitcev.lan>
	<alpine.LSU.2.11.1607041614360.25599@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Pete Zaitcev <zaitcev@kotori.zaitcev.us>

On Mon, 4 Jul 2016 17:11:05 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> On Thu, 30 Jun 2016, Pete Zaitcev wrote:
> 
> > - Sam Merritt removing monkey-patching:
> >  https://review.openstack.org/336323  

> I use a very similar patch for testing xattrs on tmpfs with xfstests.
>[...]
> But without a stronger case for user xattrs on tmpfs,
> shouldn't you and I just stick with our patches?

I don't want to rebuild kernels all the time. In addition, there's a
certain magic that distros are doing to make video on this laptop work.
So, I'm going to think over the approaches to the limitation of consumed
RAM and come back to you with a patch.

Greetings,
-- Pete

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
