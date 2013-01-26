Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 8E81A6B0009
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 19:14:25 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb11so549419pad.24
        for <linux-mm@kvack.org>; Fri, 25 Jan 2013 16:14:24 -0800 (PST)
Date: Fri, 25 Jan 2013 16:14:19 -0800
From: Jonathan Nieder <jrnieder@gmail.com>
Subject: Re: [PATCH] Subtract min_free_kbytes from dirtyable memory
Message-ID: <20130126001419.GG3341@elie.Belkin>
References: <1359118913.3146.3.camel@deadeye.wl.decadent.org.uk>
 <201301252349.r0PNnFYF024399@como.maths.usyd.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201301252349.r0PNnFYF024399@como.maths.usyd.edu.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: 695182@bugs.debian.org, ben@decadent.org.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org

Hi Paul,

paul.szabo@sydney.edu.au wrote:
> Dear Ben,

>> If you can identify where it was fixed then ...
>
> Sorry I cannot do that. I have no idea where kernel changelogs are kept.

Here are some tools.

  # prerequisite:
  apt-get install git; # as root

  # to get the kernel history:
  git clone \
    https://kernel.googlesource.com/pub/scm/linux/kernel/git/torvalds/linux.git
  cd linux

  # to view the changelog:
  git log v3.2..

  # to grep change descriptions:
  git log --grep=min_free_kbytes v3.2..

  # to view the patches corresponding to changes:
  git log --patch v3.2.. -- mm/

  # graphical interface
  apt-get install gitk; # as root
  gitk v3.2.. -- mm

  # web interface:
  w3m http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git

The "exploring git history" section of the git user manual has more
details:

  http://git-htmldocs.googlecode.com/git/user-manual.html#exploring-git-history

Thanks,
Jonathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
