From: Jesse Barnes <jbarnes@engr.sgi.com>
Subject: Re: [RFC] initialize all arches mem_map in one place
Date: Fri, 6 Aug 2004 08:57:18 -0700
References: <1091779673.6496.1021.camel@nighthawk>
In-Reply-To: <1091779673.6496.1021.camel@nighthawk>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200408060857.18641.jbarnes@engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Anton Blanchard <anton@samba.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Friday, August 6, 2004 1:07 am, Dave Hansen wrote:
> The following patch does what my first one did (don't pass mem_map into
> the init functions), incorporates Jesse Barnes' ia64 fixes on top of
> that, and gets rid of all but one of the global mem_map initializations
> (parisc is weird).  It also magically removes more code than it adds.
> It could be smaller, but I shamelessly added some comments.

Doesn't apply cleanly to the latest BK tree, which patch am I missing?

Thanks,
Jesse
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
