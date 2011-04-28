Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E95F76B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 07:36:35 -0400 (EDT)
Received: by wwi36 with SMTP id 36so2526100wwi.26
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 04:36:33 -0700 (PDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: Colin Ian King <colin.king.lkml@gmail.com>
Reply-To: colin.king@canonical.com
In-Reply-To: <1303934716.2583.22.camel@mulgrave.site>
References: <1303920553.2583.7.camel@mulgrave.site>
	 <1303921583-sup-4021@think> <1303923000.2583.8.camel@mulgrave.site>
	 <1303923177-sup-2603@think> <1303924902.2583.13.camel@mulgrave.site>
	 <1303925374-sup-7968@think>  <1303926637.2583.17.camel@mulgrave.site>
	 <1303934716.2583.22.camel@mulgrave.site>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Apr 2011 12:36:30 +0100
Message-ID: <1303990590.2081.9.camel@lenovo>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@suse.de>
Cc: Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

One more data point to add, I've been looking at an identical issue when
copying large amounts of data.  I bisected this - and the lockups occur
with commit 
3e7d344970673c5334cf7b5bb27c8c0942b06126 - before that I don't see the
issue. With this commit, my file copy test locks up after ~8-10
iterations, before this commit I can copy > 100 times and don't see the
lockup.

On Wed, 2011-04-27 at 15:05 -0500, James Bottomley wrote:
> On Wed, 2011-04-27 at 12:50 -0500, James Bottomley wrote:
> > To test the theory, Chris asked me to try with data=ordered.
> > Unfortunately, the deadlock still shows up.  This is what I get.
> 
> As another data point: I'm trying the same kernel with CONFIG_PREEMPT
> enabled.  This time the deadlock doesn't happen.  Instead, kswapd0 gets
> pegged at 99% CPU for much of the untar, but it does eventually
> complete.
> 
> James
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
