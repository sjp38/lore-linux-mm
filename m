Message-ID: <400540692.29046@ustc.edu.cn>
Date: Thu, 17 Jan 2008 11:31:25 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: [patch] Converting writeback linked lists to a tree based data structure
References: <20080115080921.70E3810653@localhost> <1200386774.15103.20.camel@twins> <532480950801150953g5a25f041ge1ad4eeb1b9bc04b@mail.gmail.com> <400452490.28636@ustc.edu.cn> <532480950801161055u4191ef1ak644dd4528ab60f8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <532480950801161055u4191ef1ak644dd4528ab60f8@mail.gmail.com>
Message-Id: <E1JFLTR-0002pn-4Y@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Rubin <mrubin@google.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 16, 2008 at 10:55:28AM -0800, Michael Rubin wrote:
> On Jan 15, 2008 7:01 PM, Fengguang Wu <wfg@mail.ustc.edu.cn> wrote:
> > Basically I think rbtree is an overkill to do time based ordering.
> > Sorry, Michael. But s_dirty would be enough for that. Plus, s_more_io
> > provides fair queuing between small/large files, and s_more_io_wait
> > provides waiting mechanism for blocked inodes.
> 
> I think the flush_tree (which is a little more than just an rbtree)
> provides the same queuing mechanisms that the three or four lists
> heads do and manages to do it in one structure. The i_flushed_when
> provides the ability to have blocked inodes wait their turn so to
> speak.
> 
> Another motivation behind the rbtree patch is to unify the data
> structure that handles the priority and mechanism of how we write out
> the pages of the inodes. There are some ideas about introducing
> priority schemes for QOS and such in the future. I am not saying this
> patch is about making that happen, but the idea is to if possible
> unify the four stages of lists into a single structure to facilitate
> efforts like that.

Yeah, rbtree is better than list_heads after all. Let's make it happen.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
