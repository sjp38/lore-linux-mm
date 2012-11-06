Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id DC24E6B005D
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 17:38:31 -0500 (EST)
Date: Tue, 6 Nov 2012 14:38:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 10/16] mm: use vm_unmapped_area() on mips architecture
Message-Id: <20121106143830.29de3bad.akpm@linux-foundation.org>
In-Reply-To: <1352155633-8648-11-git-send-email-walken@google.com>
References: <1352155633-8648-1-git-send-email-walken@google.com>
	<1352155633-8648-11-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, x86@kernel.org, William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On Mon,  5 Nov 2012 14:47:07 -0800
Michel Lespinasse <walken@google.com> wrote:

> Update the mips arch_get_unmapped_area[_topdown] functions to make
> use of vm_unmapped_area() instead of implementing a brute force search.
> 

Are the changes to the coloring equivalent to what was there before? 
It's unobvious..

COLOUR_ALIGN_DOWN() is now unused and should be removed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
