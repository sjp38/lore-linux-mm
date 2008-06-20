Date: Fri, 20 Jun 2008 12:27:33 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] - Fix stack overflow for large values of MAX_APICS
Message-ID: <20080620102733.GB32500@elte.hu>
References: <20080620025104.GA25571@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080620025104.GA25571@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, the arch/x86 maintainers <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

* Jack Steiner <steiner@sgi.com> wrote:

> physid_mask_of_physid() causes a huge stack (12k) to be created if the 
> number of APICS is large. Replace physid_mask_of_physid() with a new 
> function that does not create large stacks. This is a problem only on 
> large x86_64 systems.

ah, that indeed makes sense. Applied to tip/x86/uv - thanks Jack.

> Ingo - the "Increase MAX_APICS patch" can now works. Do you want me to 
> resend???

no need, i have reactivated it in tip/x86/uv. (after your 
physid_mask_of_physid() patch, so that it's still all bisectable)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
