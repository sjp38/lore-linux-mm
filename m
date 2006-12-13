Date: Wed, 13 Dec 2006 07:20:48 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: VM_RESERVED vs vm_normal_page()
Message-ID: <20061213132048.GB30950@lnx-holt.americas.sgi.com>
References: <1165984677.11914.159.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1165984677.11914.159.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 13, 2006 at 03:37:57PM +1100, Benjamin Herrenschmidt wrote:
> Hi folks !
> 
> What is the logic regarding VM_RESERVED, and more specifically, why is
> vm_normal_page() nor returning NULL for these ?

Near as I could ever tell from the discussion on linux-mm, it is a page
which should not be dumped.  If you have a normal page in a mapping
which you don't want swapped out, the only way I could ever figure to
prevent that from happening is by doing an extra get_user_page() on it
to add a reference.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
