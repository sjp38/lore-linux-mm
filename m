Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id ACE7A6B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 18:32:43 -0400 (EDT)
Received: by dakp5 with SMTP id p5so6066995dak.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 15:32:43 -0700 (PDT)
Date: Sat, 30 Jun 2012 07:32:35 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] vmscan: remove obsolete comment of shrinker
Message-ID: <20120629223235.GB2079@barrios>
References: <1340945500-14566-1-git-send-email-minchan@kernel.org>
 <jsk9pt$32e$2@dough.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <jsk9pt$32e$2@dough.gmane.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 29, 2012 at 01:15:43PM +0000, Cong Wang wrote:
> 
> On Fri, 29 Jun 2012 at 04:51 GMT, Minchan Kim <minchan@kernel.org> wrote:
> > 09f363c7 fixed shrinker callback returns -1 when nr_to_scan is zero
> > for preventing excessive the slab scanning. But 635697c6 fixed the
> > problem, again so we can freely return -1 although nr_to_scan is zero.
> > So let's revert 09f363c7 because the comment added in 09f363c7 made a
> > unnecessary rule shrinker user should be aware of.
> >
> 
> Please also include the subject of the commit, not just raw hash number. ;)
> 
> For example,
> 
> 09f363c7("vmscan: fix shrinker callback bug in fs/super.c")
> 635697c6("vmscan: fix initial shrinker size handling")

Yeb. It seems akpm handled it by himself.
But I will keep in mind.

Thanks, Cong!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
