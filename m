Date: Wed, 27 Aug 2003 09:03:30 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: mapped pages
Message-ID: <20030827160330.GI22495@holomorphy.com>
References: <Pine.GSO.4.51.0308271154030.24276@aria.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.51.0308271154030.24276@aria.ncl.cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 27, 2003 at 11:55:09AM -0400, Raghu R. Arur wrote:
>  Do all mapped pages have buffers? Is there a possibility that a mapped
> page to have its page->buffer to be NULL

No to the first question, yes to the second.

-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
