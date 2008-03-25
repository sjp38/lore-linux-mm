Date: Tue, 25 Mar 2008 17:41:54 +0100
From: Andreas Herrmann <andreas.herrmann3@amd.com>
Subject: Re: [PATCH] - Increase max physical memory size of x86_64
Message-ID: <20080325164154.GA5909@alberich.amd.com>
References: <20080321133157.GA10911@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080321133157.GA10911@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: mingo@elte.hu, ak@suse.de, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 21, 2008 at 08:31:57AM -0500, Jack Steiner wrote:
> Increase the maximum physical address size of x86_64 system
> to 44-bits. This is in preparation for future chips that
> support larger physical memory sizes.

Shouldn't this be increased to 48?
AMD family 10h CPUs actually support 48 bits for the
physical address.


Regards,

Andreas


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
