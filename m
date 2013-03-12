Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 824246B0037
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 13:03:45 -0400 (EDT)
Date: Tue, 12 Mar 2013 13:03:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Swap defragging
Message-ID: <20130312170339.GD1953@cmpxchg.org>
References: <CAGDaZ_rvfrBVCKMuEdPcSod684xwbUf9Aj4nbas4_vcG3V9yfg@mail.gmail.com>
 <20130308023511.GD23767@cmpxchg.org>
 <513D4B5E.6050601@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <513D4B5E.6050601@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Raymond Jennings <shentino@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Mar 11, 2013 at 11:11:26AM +0800, Simon Jeons wrote:
> Hi Johannes,
> On 03/08/2013 10:35 AM, Johannes Weiner wrote:
> >On Thu, Mar 07, 2013 at 06:07:23PM -0800, Raymond Jennings wrote:
> >>Just a two cent question, but is there any merit to having the kernel
> >>defragment swap space?
> >That is a good question.
> 
> One question here:
> 
> The comments of setup_swap_extents:
> An ordered list of swap extents is built at swapon time and is then
> used at swap_writepage/swap_readpage tiem for locating where on disk
> a page belongs.
> But I didn't see any handle of swap extents in
> swap_writepage/swap_readpage, why?

This is not the right place for such questions.  If you are interested
in how the kernel works, buy a book, read the code, consult the kernel
newbies project if you get stuck.

Also, the answer to your question is within a few lines of each other
in that same code file.  Make an effort.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
