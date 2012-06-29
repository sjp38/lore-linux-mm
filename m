Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id D9F166B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 09:16:00 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1Skb3E-0007Vx-S4
	for linux-mm@kvack.org; Fri, 29 Jun 2012 15:15:56 +0200
Received: from 117.57.110.131 ([117.57.110.131])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 15:15:56 +0200
Received: from xiyou.wangcong by 117.57.110.131 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 15:15:56 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] vmscan: remove obsolete comment of shrinker
Date: Fri, 29 Jun 2012 13:15:43 +0000 (UTC)
Message-ID: <jsk9pt$32e$2@dough.gmane.org>
References: <1340945500-14566-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org


On Fri, 29 Jun 2012 at 04:51 GMT, Minchan Kim <minchan@kernel.org> wrote:
> 09f363c7 fixed shrinker callback returns -1 when nr_to_scan is zero
> for preventing excessive the slab scanning. But 635697c6 fixed the
> problem, again so we can freely return -1 although nr_to_scan is zero.
> So let's revert 09f363c7 because the comment added in 09f363c7 made a
> unnecessary rule shrinker user should be aware of.
>

Please also include the subject of the commit, not just raw hash number. ;)

For example,

09f363c7("vmscan: fix shrinker callback bug in fs/super.c")
635697c6("vmscan: fix initial shrinker size handling")

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
