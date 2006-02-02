From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Dynamically allocated pageflags
Date: Thu, 2 Feb 2006 14:31:29 +0100
References: <200602022111.32930.ncunningham@cyclades.com>
In-Reply-To: <200602022111.32930.ncunningham@cyclades.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602021431.30194.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nigel Cunningham <ncunningham@cyclades.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thursday 02 February 2006 12:11, Nigel Cunningham wrote:
> Hi everyone.
> 
> This is my latest revision of the dynamically allocated pageflags patch.
> 
> The patch is useful for kernel space applications that sometimes need to flag
> pages for some purpose, but don't otherwise need the retain the state. A prime
> example is suspend-to-disk, which needs to flag pages as unsaveable, allocated
> by suspend-to-disk and the like while it is working, but doesn't need to
> retain any of this state between cycles.

It looks like total overkill for a simple problem to me. And is there really
any other user of this other than swsusp?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
