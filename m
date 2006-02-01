Date: Wed, 1 Feb 2006 14:06:50 +0900
From: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Subject: Re: [ckrm-tech] [PATCH 1/8] Add the __GFP_NOLRU flag
In-Reply-To: <1138731533.6424.2.camel@localhost.localdomain>
References: <20060131023000.7915.71955.sendpatchset@debian>
	<20060131023005.7915.10365.sendpatchset@debian>
	<1138731533.6424.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20060201050650.CC4FF74032@sv1.valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 31 Jan 2006 10:18:53 -0800
Dave Hansen <haveblue@us.ibm.com> wrote:

> > This patch adds the __GFP_NOLRU flag.  This option should be used 
> > for GFP_USER/GFP_HIGHUSER page allocations that are not maintained
> > in the zone LRU lists.
> 
> Is this simply to mark pages which will never end up in the LRU?  Why is
> this important?

The resource controller assumes that pages in pzones are linked to
LRU lists or free lists in order to simplify the cleanup of pzones
in classes.  Cleaning up a pzone needs to know all the pages that
belong to the pzone.  So the resource controller is designed not to 
allocate pages from pzones that will never end up in the LRU.

-- 
KUROSAWA, Takahiro

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
