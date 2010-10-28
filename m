Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 37BFE8D0015
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 10:03:53 -0400 (EDT)
Subject: Re: [PATCH] parisc: fix compile failure with kmap_atomic changes
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <20101028051807.539484D30@hiauly1.hia.nrc.ca>
References: <20101028051807.539484D30@hiauly1.hia.nrc.ca>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Oct 2010 09:03:49 -0500
Message-ID: <1288274629.3043.1.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: John David Anglin <dave@hiauly1.hia.nrc.ca>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-parisc@vger.kernel.org, peterz@infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-10-28 at 01:18 -0400, John David Anglin wrote:
> Signed-off-by: John David Anglin  <dave.anglin@nrc-cnrc.gc.ca>
> 
> Sent effectively the same change to parisc-linux list months ago...

You did?  Why didn't you send it to Peter?  When I grumbled at him on
IRC for breaking parisc (as well as quite a few other 64 bit
architectures in mainline) he had no idea there was a problem.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
