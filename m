From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 16/32] x86, mm: simplify get_user_pages() PTE bit
 handling
Date: Mon, 14 Dec 2015 20:56:07 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1512142055510.4336@nanos>
References: <20151214190542.39C4886D@viggo.jf.intel.com> <20151214190610.FBAB486D@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151214190610.FBAB486D@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com
List-Id: linux-mm.kvack.org

On Mon, 14 Dec 2015, Dave Hansen wrote:
> The current get_user_pages() code is a wee bit more complicated
> than it needs to be for pte bit checking.  Currently, it establishes
> a mask of required pte _PAGE_* bits and ensures that the pte it
> goes after has all those bits.
> 
> This consolidates the three identical copies of this code.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
