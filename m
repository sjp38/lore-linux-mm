From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 14/32] x86, pkeys: add functions to fetch PKRU
Date: Mon, 14 Dec 2015 20:56:34 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1512142056220.4336@nanos>
References: <20151214190542.39C4886D@viggo.jf.intel.com> <20151214190607.8D59DC37@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151214190607.8D59DC37@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com
List-Id: linux-mm.kvack.org

On Mon, 14 Dec 2015, Dave Hansen wrote:
> This adds the raw instruction to access PKRU as well as some
> accessor functions that correctly handle when the CPU does not
> support the instruction.  We don't use it here, but we will use
> read_pkru() in the next patch.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
