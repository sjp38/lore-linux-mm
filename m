Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id A87786B0037
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 10:31:57 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id d1so9587572wiv.3
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 07:31:57 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id a6si10725740wik.100.2014.09.25.07.31.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 25 Sep 2014 07:31:56 -0700 (PDT)
Date: Thu, 25 Sep 2014 15:31:42 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH resend] arm:extend the reserved memory for initrd to be
	page aligned
Message-ID: <20140925143142.GF5182@n2100.arm.linux.org.uk>
References: <35FD53F367049845BC99AC72306C23D103D6DB49161F@CNBJMBX05.corpusers.net> <20140919095959.GA2295@e104818-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140919095959.GA2295@e104818-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: Will Deacon <Will.Deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>, 'Uwe =?iso-8859-1?Q?Kleine-K=F6nig'?= <u.kleine-koenig@pengutronix.de>, DL-WW-ContributionOfficers-Linux <DL-WW-ContributionOfficers-Linux@sonymobile.com>

On Fri, Sep 19, 2014 at 11:00:02AM +0100, Catalin Marinas wrote:
> On Fri, Sep 19, 2014 at 08:09:47AM +0100, Wang, Yalin wrote:
> > this patch extend the start and end address of initrd to be page aligned,
> > so that we can free all memory including the un-page aligned head or tail
> > page of initrd, if the start or end address of initrd are not page
> > aligned, the page can't be freed by free_initrd_mem() function.
> > 
> > Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> 
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> 
> (as I said, if Russell doesn't have any objections please send the patch
> to his patch system)

I now have an objection.  The patches in the emails were properly formatted.
The patches which were submitted to the patch system (there's two of them
doing the same thing...) are not:

--- ../kernel.torvalds.git.origin/arch/arm/mm/init.c    2014-09-24 16:24:06.863759000 +0800
+++ arch/arm/mm/init.c  2014-09-24 16:27:11.455456000 +0800

This is totally broken.  Let's read the patch(1) man page:

       First, patch takes an ordered list of candidate file names as follows:

        . If the header is that of a context diff, patch takes the old and new
          file  names  in  the  header.  A name is ignored if it does not have
          enough slashes to satisfy the -pnum or --strip=num option.  The name
          /dev/null is also ignored.

        . If  there is an Index: line in the leading garbage and if either the
          old and new names are both absent  or  if  patch  is  conforming  to
          POSIX, patch takes the name in the Index: line.

        . For the purpose of the following rules, the candidate file names are
          considered to be in the order (old, new, index), regardless  of  the
          order that they appear in the header.

       Then patch selects a file name from the candidate list as follows:

        . If  some  of  the named files exist, patch selects the first name if
          conforming to POSIX, and the best name otherwise.
...
        . If no named files exist, no RCS, ClearCase, Perforce, or SCCS master
          was found, some names are given, patch is not conforming  to  POSIX,
          and  the patch appears to create a file, patch selects the best name
          requiring the creation of the fewest directories.

        . If no file name results from the above heuristics, you are asked for
          the name of the file to patch, and patch selects that name.

...

NOTES FOR PATCH SENDERS
       There are several things you should bear in mind if you are going to be
       sending out patches.
...
       If the recipient is supposed to use the -pN option, do not send  output
       that looks like this:

          diff -Naur v2.0.29/prog/README prog/README
          --- v2.0.29/prog/README   Mon Mar 10 15:13:12 1997
          +++ prog/README   Mon Mar 17 14:58:22 1997

       because  the two file names have different numbers of slashes, and dif-
       ferent versions of patch interpret  the  file  names  differently.   To
       avoid confusion, send output that looks like this instead:

          diff -Naur v2.0.29/prog/README v2.0.30/prog/README
          --- v2.0.29/prog/README   Mon Mar 10 15:13:12 1997
          +++ v2.0.30/prog/README   Mon Mar 17 14:58:22 1997

So I'm going to reject this crap.

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
