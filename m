Message-ID: <48AC4B41.8080908@linux-foundation.org>
Date: Wed, 20 Aug 2008 11:50:09 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [patch] mm: rewrite vmap layer
References: <20080818133224.GA5258@wotan.suse.de> <48AADBDC.2000608@linux-foundation.org> <20080820090234.GA7018@wotan.suse.de> <48AC244F.1030104@linux-foundation.org> <20080820162235.GA26894@wotan.suse.de>
In-Reply-To: <20080820162235.GA26894@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> Indeed that would be a good use for it if this general fallback mechanism
> were to be merged.

Want me to rebase my virtualizable compound patchset on top of your vmap changes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
