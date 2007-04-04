Subject: Re: [PATCH 0/14] Pass MAP_FIXED down to get_unmapped_area
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1175659285.929428.835270667964.qpush@grosgo>
References: <1175659285.929428.835270667964.qpush@grosgo>
Content-Type: text/plain
Date: Wed, 04 Apr 2007 14:03:48 +1000
Message-Id: <1175659428.30879.47.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-04-04 at 14:01 +1000, Benjamin Herrenschmidt wrote:
> This is a "first step" as there are still cleanups to be done in various
> areas touched by that code but I think it's probably good to go as is and
> at least enables me to implement what I need for PowerPC.


 .../...

And sorry for the double-send of some of the patches, a script hickup on
my side.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
