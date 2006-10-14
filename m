From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: [patch 3/3] mm: fault handler to replace nopage and populate
Date: Sat, 14 Oct 2006 15:28:48 +0200
References: <20061007105758.14024.70048.sendpatchset@linux.site> <5c77e7070610120456t1bdaa95cre611080c9c953582@mail.gmail.com> <20061012120735.GA20191@wotan.suse.de>
In-Reply-To: <20061012120735.GA20191@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200610141528.50542.ioe-lkml@rameria.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Carsten Otte <cotte.de@gmail.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Thursday, 12. October 2006 14:07, Nick Piggin wrote:
> Actually, filemap_xip needs some attention I think... if xip files
> can be truncated or invalidated (I assume they can), then we need to
> lock the page, validate that it is the correct one and not truncated,
> and return with it locked.

???

Isn't XIP for "eXecuting In Place" from ROM or FLASH?
How to truncate these? I thought the whole idea of
XIP was a pure RO mapping?

They should be valid from mount to umount.

Regards

Ingo Oeser, a bit puzzled about that...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
