Received: from imladris.surriel.com ([IPv6:::ffff:127.0.0.1]:28105 "EHLO
	localhost") by imladris.surriel.com with ESMTP id S83930AbTJMSv4
	(ORCPT <rfc822;linux-mm@kvack.org>); Mon, 13 Oct 2003 14:51:56 -0400
Date: Mon, 13 Oct 2003 14:51:55 -0400 (EDT)
From: Rik van Riel <riel@surriel.com>
Subject: Re: [RFC] State of ru_majflt
In-Reply-To: <20031013165104.GA14720@k3.hellgate.ch>
Message-ID: <Pine.LNX.4.55L.0310131451310.27244@imladris.surriel.com>
References: <20031013165104.GA14720@k3.hellgate.ch>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Luethi <rl@hellgate.ch>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 13 Oct 2003, Roger Luethi wrote:

> A proper solution would probably have filemap_nopage tell its caller the
> correct return code.

Agreed.

> Is this considered a bug or is it a documentation issue? How much do we
> care?

It's a bug, but I'm not quite sure how much we care.

Rik
-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
