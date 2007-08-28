Date: Mon, 27 Aug 2007 22:34:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH/RFC]  Add node 'states' sysfs class attribute - V2
Message-Id: <20070827223401.20230eb1.akpm@linux-foundation.org>
In-Reply-To: <20070827222912.8b364352.akpm@linux-foundation.org>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
	<1188248528.5952.95.camel@localhost>
	<20070827170159.0a79529d.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708271702520.1787@schroedinger.engr.sgi.com>
	<20070827181405.57a3d8fe.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708271826180.10344@schroedinger.engr.sgi.com>
	<20070827201822.2506b888.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708272210210.9748@schroedinger.engr.sgi.com>
	<20070827222912.8b364352.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007 22:29:12 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> >  Even if you do this: It will significantly slow us 
> > down always having to come to you and ask you for a tool.
> 
> Your claim here is, I believe, that a human user interface should be
> implemented in the kernel because the cost (to you) (short-term) of doing
> that is lower that the cost of implementing a simpler kernel interface and
> a bit of userspace human presentation code.  Even though the long-term
> cost to the kernel maintainers is higher, and the resulting output is
> harder for programs to parse.

oh, hang on.  We've already implemented that bitmap_scnlistprintf() monstrosity
and we're presumably using it in sysfs, so tools already need to know how
to parse it all.

Sigh, so it's too late to fix it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
