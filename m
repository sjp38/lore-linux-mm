Date: Thu, 20 Feb 2003 15:10:27 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH 2.5.62] Support for remap_page_range in objrmap
Message-ID: <178650000.1045782627@flay>
In-Reply-To: <121000000.1045777999@baldur.austin.ibm.com>
References: <121000000.1045777999@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Here's the fix we discussed for remap_page_range.  It sets the anon flag
> for pages in any vma used for nonlinear.  It also requires that
> MAP_NONLINEAR be passed in at mmap time to flag the vma.

Using the page based mechanism might also clear up some people's 
concerns about small windows onto large shared areas for Oracle,
which will probably be using these nonlinear mappings anyway.
Yes, I'm sure there are other corner cases that need to be addressed
as well ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
