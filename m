Date: Tue, 27 May 2008 10:03:50 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] 2.6.26-rc: x86: pci-dma.c: use __GFP_NO_OOM instead of
	__GFP_NORETRY
Message-ID: <20080527080349.GE29246@elte.hu>
References: <20080526234940.GA1376@xs4all.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080526234940.GA1376@xs4all.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miquel van Smoorenburg <mikevs@xs4all.net>
Cc: Andi Kleen <andi@firstfloor.org>, Glauber Costa <gcosta@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Jesse Barnes <jbarnes@virtuousgeek.org>
List-ID: <linux-mm.kvack.org>

* Miquel van Smoorenburg <mikevs@xs4all.net> wrote:

> Please consider the below patch for 2.6.26 (can somebody from the x86 
> team pick this up please? Thank you)

looks good to me in principle - but it should go via -mm as it touches 
mm/page_alloc.c. Andrew: this fix is for v2.6.26.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
