Subject: Re: [PATCH] dirty bit clearing on s390.
Message-ID: <OFD743E8B0.5C908A4A-ONC1256D32.0023029F@de.ibm.com>
From: "Martin Schwidefsky" <schwidefsky@de.ibm.com>
Date: Mon, 26 May 2003 08:24:09 +0200
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org, phillips@arcor.de
List-ID: <linux-mm.kvack.org>

> Having thought long and hard about this, yes, I don't really see anything
> saner than just hooking into SetPageUptodate as you have done.
>
> Just to be sure that I understand the issues here I'll cook up a new
> changelog for this and run it by you, then submit it.

Good, so we haven't been too far off with our approach. Thanks for the
review.

blue skies,
   Martin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
