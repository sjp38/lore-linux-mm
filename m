Date: Thu, 12 Oct 2006 14:07:35 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/3] mm: fault handler to replace nopage and populate
Message-ID: <20061012120735.GA20191@wotan.suse.de>
References: <20061007105758.14024.70048.sendpatchset@linux.site> <20061007105853.14024.95383.sendpatchset@linux.site> <5c77e7070610120456t1bdaa95cre611080c9c953582@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5c77e7070610120456t1bdaa95cre611080c9c953582@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carsten Otte <cotte.de@gmail.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 12, 2006 at 01:56:38PM +0200, Carsten Otte wrote:
> As for the filemap_xip changes, looks nice as far as I can tell. I will test
> that change for xip.

Actually, filemap_xip needs some attention I think... if xip files
can be truncated or invalidated (I assume they can), then we need to
lock the page, validate that it is the correct one and not truncated,
and return with it locked.

That should be as simple as just locking the page and rechecking i_size,
but maybe the zero page can be handled better... I don't know?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
