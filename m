Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 377F56B003C
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 21:48:49 -0400 (EDT)
Date: Mon, 8 Apr 2013 10:48:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC] mm: remove swapcache page early
Message-ID: <20130408014845.GB6394@blaptop>
References: <1364350932-12853-1-git-send-email-minchan@kernel.org>
 <alpine.LNX.2.00.1303271230210.29687@eggly.anvils>
 <515ADFCF.4010209@gmail.com>
 <51611F94.7060801@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51611F94.7060801@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hello Simon,

On Sun, Apr 07, 2013 at 03:26:12PM +0800, Simon Jeons wrote:
> Ping Minchan.
> On 04/02/2013 09:40 PM, Simon Jeons wrote:
> >Hi Hugh,
> >On 03/28/2013 05:41 AM, Hugh Dickins wrote:
> >>On Wed, 27 Mar 2013, Minchan Kim wrote:
> >>
> >>>Swap subsystem does lazy swap slot free with expecting the page
> >>>would be swapped out again so we can't avoid unnecessary write.
> >>                              so we can avoid unnecessary write.
> >
> >If page can be swap out again, which codes can avoid unnecessary
> >write? Could you point out to me? Thanks in advance. ;-)

Look at shrink_page_list.

1) PageAnon(page) && !PageSwapCache() 
2) add_to_swap's SetPageDirty
3) __remove_mapping

P.S)
It seems you are misunderstanding. Here isn't proper place to ask a
question for your understanding the code. As I know, there are some
project(ex, kernelnewbies) and books for study and sharing the
knowledge linux kernel.

I recommend Mel's "Understand the Linux Virtual Memory Manager".
It's rather outdated but will be very helpful to understand VM of
linux kernel. You can get it freely but I hope you pay for.
So if author become a billionaire by selecting best book in Amazon,
he might print out second edition which covers all of new VM features
and may solve all of you curiosity.

It would be a another method to contribute open source project. :)

I believe you talented developers can catch it up with reading the
code enoughly and find more bonus knowledge. I think it's why our senior
developers yell out RTFM and I follow them.

Cheers!


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
