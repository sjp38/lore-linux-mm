Date: Thu, 15 Mar 2007 11:07:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
Message-Id: <20070315110735.287c8a23.akpm@linux-foundation.org>
In-Reply-To: <Pine.GSO.4.64.0703150045550.18191@cpu102.cs.uwaterloo.ca>
References: <Pine.GSO.4.64.0703081612290.1080@cpu102.cs.uwaterloo.ca>
	<20070312142012.GH30777@atrey.karlin.mff.cuni.cz>
	<20070312143900.GB6016@wotan.suse.de>
	<20070312151355.GB23532@duck.suse.cz>
	<Pine.GSO.4.64.0703121247210.7679@cpu102.cs.uwaterloo.ca>
	<20070312173500.GF23532@duck.suse.cz>
	<Pine.GSO.4.64.0703131438580.8193@cpu102.cs.uwaterloo.ca>
	<20070313185554.GA5105@duck.suse.cz>
	<Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca>
	<1173905741.8763.36.camel@kleikamp.austin.ibm.com>
	<20070314213317.GA22234@rhlx01.hs-esslingen.de>
	<1173910138.8763.45.camel@kleikamp.austin.ibm.com>
	<45F8A301.90301@cse.ohio-state.edu>
	<Pine.GSO.4.64.0703150045550.18191@cpu102.cs.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ashif Harji <asharji@cs.uwaterloo.ca>
Cc: dingxn@cse.ohio-state.edu, shaggy@linux.vnet.ibm.com, andi@rhlx01.fht-esslingen.de, linux-mm@kvack.org, npiggin@suse.de, jack@suse.cz, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Thu, 15 Mar 2007 01:22:45 -0400 (EDT) Ashif Harji <asharji@cs.uwaterloo.ca> wrote:
> I still think the simple fix of removing the 
> condition is the best approach, but I'm certainly open to alternatives.

Yes, the problem of falsely activating pages when the file is read in small
hunks is worse than the problem which your patch fixes.

We could change it so that if the current read() includes the zeroeth byte
of the page, we run mark_page_accessed() even if this_page==prev_page?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
