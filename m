Date: Fri, 28 Mar 2008 21:13:37 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/8] - Support for UV platform
Message-ID: <20080328201337.GA26555@elte.hu>
References: <20080328191156.GA16415@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080328191156.GA16415@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

* Jack Steiner <steiner@sgi.com> wrote:

> This series of patches add x86_64 support for the SGI "UV" platform. 
> Most of the changes are related to support for larger apic IDs and new 
> chipset hardware that is used for sending IPIs, etc.

thanks Jack, applied.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
