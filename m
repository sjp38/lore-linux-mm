Subject: Re: [patch 1/3] add the fsblock layer
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <p73fy4h5q3c.fsf@bingen.suse.de>
References: <20070624014528.GA17609@wotan.suse.de>
	 <20070624014613.GB17609@wotan.suse.de>  <p73fy4h5q3c.fsf@bingen.suse.de>
Content-Type: text/plain
Date: Sun, 24 Jun 2007 13:18:42 -0700
Message-Id: <1182716322.6819.3.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Hmm, could define a macro DECLARE_ATOMIC_BITMAP(maxbit) that expands to the smallest
> possible type for each architecture. And a couple of ugly casts for set_bit et.al.
> but those could be also hidden in macros. Should be relatively easy to do.

or make a "smallbit" type that is small/supported, so 64 bit if 32 bit
isn't supported, otherwise 32


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
