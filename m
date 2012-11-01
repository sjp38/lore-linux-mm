Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 92E716B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 22:39:37 -0400 (EDT)
Date: Thu, 1 Nov 2012 11:45:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 0/3] zram/zsmalloc promotion
Message-ID: <20121101024536.GC24883@bbox>
References: <1351501009-15111-1-git-send-email-minchan@kernel.org>
 <20121031010642.GN15767@bbox>
 <20121031014209.GB2672@kroah.com>
 <20121031020443.GP15767@bbox>
 <20121031021618.GA1142@kroah.com>
 <20121031023947.GA24883@bbox>
 <20121031024307.GA9210@kroah.com>
 <20121031070202.GR15767@bbox>
 <20121031161900.GG31804@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121031161900.GG31804@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jens Axboe <axboe@kernel.dk>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@cs.helsinki.fi>, gaowanlong@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 31, 2012 at 09:19:00AM -0700, Greg Kroah-Hartman wrote:
> On Wed, Oct 31, 2012 at 04:02:02PM +0900, Minchan Kim wrote:
> > On Tue, Oct 30, 2012 at 07:43:07PM -0700, Greg Kroah-Hartman wrote:
> > > On Wed, Oct 31, 2012 at 11:39:48AM +0900, Minchan Kim wrote:
> > > > Greg, what do you think about LTSI?
> > > > Is it proper feature to add it? For it, still do I need ACK from mm developers?
> > > 
> > > It's already in LTSI, as it's in the 3.4 kernel, right?
> > 
> > Right. But as I look, it seems to be based on 3.4.11 which doesn't have
> > recent bug fix and enhances and current 3.4.16 also doesn't include it.
> 
> You can ask for those bugfixes to get backported to the stable/longterm
> kernel tree, see Documentation/stable_kernel_rules.txt for how to do
> this properly.
> 
> > Just out of curiosity.
> > 
> > Is there any rule about update period in long-term kernel?
> > I mean how often you release long-term kernel.
> 
> About once a week lately.
> 
> > Is there any rule about update period in LTSI kernel based on long-term kernel?
> 
> No, the LTSI kernel work has been slow due to the lack of time on my
> part lately.
> 
> > If I get the answer on above two quesion, I can expect later what LTSI kernel
> > version include feature I need.
> > 
> > Another question.
> > For example, There is A feature in mainline and A has no problem but
> > someone invents new wheel "B" which is better than A so it replace A totally
> > in recent mainline. As following stable-kernel rule, it's not a real bug fix
> > so I guess stable kernel will never replace A with B.
> 
> That is correct.
> 
> > It means LTSI never get a chance to use new wheel. Right?
> 
> No, you can submit the same patches for the LTSI kernel as well, they
> will probably be accepted as the rules are much more "loose" for the
> LTSI tree compared to the normal stable/longterm kernel rules.  Which is
> the primary reason it is around.
> 
> Hope this helps,
> 
> greg k-h

Thanks, Greg!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
