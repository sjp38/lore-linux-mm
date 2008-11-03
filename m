Date: Mon, 3 Nov 2008 10:03:15 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] [RESEND] x86: add memory hotremove config option
Message-ID: <20081103090315.GH11730@elte.hu>
References: <20081031175203.GA7483@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081031175203.GA7483@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: linux-mm@kvack.org, Yasunori Goto <y-goto@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

* Gary Hade <garyhade@us.ibm.com> wrote:

> I am resending this patch (originally posted by Badari Pulavarty)
> since the "mm: cleanup to make remove_memory() arch-neutral" patch
> on which it depends is now in Linus' 2.6.git tree (commit
> 71088785c6bc68fddb450063d57b1bd1c78e0ea1) and 2.6.28-rc2.
> 
> Thanks,
> Gary
> 
> ---
> Add memory hotremove config option to x86
> 
> Memory hotremove functionality can currently be configured into
> the ia64, powerpc, and s390 kernels.  This patch makes it possible
> to configure the memory hotremove functionality into the x86
> kernel as well.
> 
> Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
> Signed-off-by: Gary Hade <garyhade@us.ibm.com>

applied to tip/x86/mm, thanks!

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
