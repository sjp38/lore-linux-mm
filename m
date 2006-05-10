Subject: Re: [PATCH] mm: cleanup swap unused warning
From: Daniel Walker <dwalker@mvista.com>
In-Reply-To: <20060510043834.70f40ddc.akpm@osdl.org>
References: <200605102132.41217.kernel@kolivas.org>
	 <20060510043834.70f40ddc.akpm@osdl.org>
Content-Type: text/plain
Date: Wed, 10 May 2006 11:20:55 -0700
Message-Id: <1147285256.21536.132.camel@c-67-180-134-207.hsd1.ca.comcast.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Con Kolivas <kernel@kolivas.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-05-10 at 04:38 -0700, Andrew Morton wrote:
> Con Kolivas <kernel@kolivas.org> wrote:
> >
> > Are there any users of swp_entry_t when CONFIG_SWAP is not defined?
> 
> Well there shouldn't be.  Making accesses to swp_entry_t.val fail to
> compile if !CONFIG_SWAP might be useful.

In mm/vmscan.c line 387 it defined swp_entry_t and sets val regardless
of CONFIG_SWAP , but the value never really gets used .. Showed up in my
warning reviews.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
