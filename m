Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1B0236B009C
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 13:48:34 -0500 (EST)
Date: Tue, 2 Feb 2010 19:48:31 +0100
From: Olivier Galibert <galibert@pobox.com>
Subject: Re: [PATCH 10/11] readahead: dont do start-of-file readahead after lseek()
Message-ID: <20100202184831.GD75577@dspnet.fr.eu.org>
References: <20100202152835.683907822@intel.com> <20100202153317.644170708@intel.com> <20100202181321.GB75577@dspnet.fr.eu.org> <alpine.LFD.2.00.1002021037110.3664@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1002021037110.3664@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 02, 2010 at 10:40:41AM -0800, Linus Torvalds wrote:
> IOW, if you start off with a SEEK_END, I think it's reasonable to expect 
> it to _not_ read the whole thing.

I've seen a lot of:
  int fd = open(...);
  size = lseek(fd, 0, SEEK_END);
  lseek(fd, 0, SEEK_SET);

  data = malloc(size);
  read(fd, data, size);
  close(fd);

Why not fstat?  I don't know.  Perhaps a case of cargo culting,
perhaps a case of "other unixes suck for portability"[1].  But it's
probably still there a lot in real code.

  OG.

[1] In the hpux, dgux, sunos, etc sense.  Not to be taken as a comment
    on modern BSDs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
