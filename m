Date: Thu, 8 Jun 2000 12:13:13 -0700
From: Chip Salzenberg <chip@valinux.com>
Subject: Re: raid0 and buffers larger than PAGE_SIZE
Message-ID: <20000608121312.A601@perlsupport.com>
References: <20000607204444.A453@perlsupport.com> <20000608150821.G3886@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000608150821.G3886@redhat.com>; from sct@redhat.com on Thu, Jun 08, 2000 at 03:08:21PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

According to Stephen C. Tweedie:
> getblk() with blocksize > PAGE_SIZE is completely illegal.

Well, that answers _that_ question.

> Are you using a decent set of raid patches?

No patches, and apparently not decent.  :-(  I looked around with
google and on ftp.kernel.org, but I couldn't find anything current.

Can you spare a URL for a fellow programmer down on his luck?
-- 
Chip Salzenberg              - a.k.a. -              <chip@valinux.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
