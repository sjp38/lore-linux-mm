Date: Wed, 15 Oct 2003 14:40:04 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.6.0-test7-mm1
Message-ID: <20031015214004.GC723@holomorphy.com>
References: <20031015013649.4aebc910.akpm@osdl.org> <1066232576.25102.1.camel@telecentrolivre> <20031015165508.GA723@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031015165508.GA723@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Luiz Capitulino <lcapitulino@prefeitura.sp.gov.br>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 15, 2003 at 09:55:08AM -0700, William Lee Irwin III wrote:
> Okay, this one's me. I should have tried DEBUG_PAGEALLOC when testing.

I can't reproduce it here, can you retry with the invalidate_inodes-speedup
patch backed out?


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
