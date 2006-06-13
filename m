From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH]: Adding a counter in vma to indicate the number =?iso-8859-15?q?of=09physical_pages_backing?= it
Date: Tue, 13 Jun 2006 19:31:36 +0200
References: <1149903235.31417.84.camel@galaxy.corp.google.com> <200606130551.23825.ak@suse.de> <1150217948.9576.67.camel@galaxy.corp.google.com>
In-Reply-To: <1150217948.9576.67.camel@galaxy.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606131931.36165.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rohitseth@google.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, Linux-mm@kvack.org, Linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

 
> This information is for user land applications to have the knowledge of
> which virtual ranges are getting actively used and which are not.

If you think the kernel needs better information on that wouldn't
it be better to use the page accessed bits of the hardware more
aggressively?

Before giving up and adding hacks like you're proposing it would
be better to explore fully automatic mechanisms fully.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
