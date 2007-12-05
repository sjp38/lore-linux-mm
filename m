Date: Wed, 5 Dec 2007 14:47:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 17/18] mm: remove nopage
Message-Id: <20071205144700.729a0c98.akpm@linux-foundation.org>
In-Reply-To: <20071205071628.547577000@nick.local0.net>
References: <20071205071547.701344000@nick.local0.net>
	<20071205071628.547577000@nick.local0.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 05 Dec 2007 18:16:04 +1100
npiggin@suse.de wrote:

> Nothing in the tree uses nopage any more. Remove support for it in the
> core mm code and documentation (and a few stray references to it in comments).

I'll duck this for now.  It's going to take a long time to get all those
other patches merged given my usual ~75% dropped-on-the-floor rate from
subsystem maintainers.  Please resend when mainline is nopage-free.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
