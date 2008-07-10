Date: Thu, 10 Jul 2008 01:35:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] - Map UV chipset space - pagetable
Message-Id: <20080710013533.e059f556.akpm@linux-foundation.org>
In-Reply-To: <20080701194532.GA28405@sgi.com>
References: <20080701194532.GA28405@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jul 2008 14:45:32 -0500 Jack Steiner <steiner@sgi.com> wrote:

> +	BUG_ON((phys & ~PMD_MASK) || (size & ~PMD_MASK));

BUG_ON(A || B) is usually a bad idea.  If it goes bang, you'll really wish
that it had been

	BUG_ON(A);
	BUG_ON(B);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
