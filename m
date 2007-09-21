Date: Fri, 21 Sep 2007 03:16:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/1] x86: Reduce Memory Usage for large CPU count
 systems v2
Message-Id: <20070921031606.055ab52e.akpm@linux-foundation.org>
In-Reply-To: <20070920213004.527735000@sgi.com>
References: <20070920213004.527735000@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Sep 2007 14:30:04 -0700 travis@sgi.com wrote:

> Obviously, the IRQ arrays are of greater importance for
> size reduction.  Any suggestions, or threads I should read
> are gratefully accecpted... ;-)

hard.  Convert them to a radix-tree I suppose.  powerpc alrady does that
but it open-codes it in some fashion.  Don't look at it ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
