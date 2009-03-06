Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 32C0A6B0083
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 16:10:13 -0500 (EST)
Date: Fri, 6 Mar 2009 13:13:36 -0800
From: mark gross <mgross@linux.intel.com>
Subject: Re: possible bug in find_get_pages
Message-ID: <20090306211336.GA5981@linux.intel.com>
Reply-To: mgross@linux.intel.com
References: <20090306192625.GA3267@linux.intel.com> <alpine.DEB.1.10.0903061426190.20182@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903061426190.20182@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, Mar 06, 2009 at 02:28:50PM -0500, Christoph Lameter wrote:
> On Fri, 6 Mar 2009, mark gross wrote:
> 
> > It seems that page->_count == 0 at some point on some overnight runs
> > with locks the system into a tight loop from the repeat: and a goto
> > repeat in find_get_pages.
> 
> A page with ref count zero should not be in any mapping. If the page is in
> a mapping then the page is used. Therefore the refcount should be > 0.
> 
> If there is a page with zero refcount and its in a mapping then something
> erroneously decreased the refcount.
> 
> Nick wrote the code so I CCed him.

thanks!  This is on early hardware so perhaps there isn't anything to
see here.  

Still form a static read of the code that goto repeat raises
eyebrows as why would anyone expect to get anything different from
radix_page_deref_slot calling it again with the same arguments?

--mgross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
