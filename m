From: Andi Kleen <ak@suse.de>
Subject: Re: mbind and alignment
Date: Wed, 4 Apr 2007 13:52:04 +0200
References: <20070402204202.GC3316@interface.famille.thibault.fr>
In-Reply-To: <20070402204202.GC3316@interface.famille.thibault.fr>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200704041352.04525.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Samuel Thibault <samuel.thibault@ens-lyon.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> So one of those should probably be done to free people from headaches:
> 
> - document "start" requirement in the manual page
> - require len to be aligned too, and document the requirements in the
>   manual page
> - drop the "start" requirement and just round down the page + adjust
>   size automatically.

This annoyed me in the past too. The kernel should have done that alignment
by itself. But changing it now would be a bad idea because it would
produce programs that run on newer kernels but break on olders.
Documenting it is the only sane option left.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
