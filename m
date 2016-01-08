From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 14/31] x86, pkeys: add functions to fetch PKRU
Date: Fri, 8 Jan 2016 20:32:49 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1601082032290.3575@nanos>
References: <20160107000104.1A105322@viggo.jf.intel.com> <20160107000125.E86B6147@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160107000125.E86B6147@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com
List-Id: linux-mm.kvack.org

On Wed, 6 Jan 2016, Dave Hansen wrote:

> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> This adds the raw instruction to access PKRU as well as some
> accessor functions that correctly handle when the CPU does not
> support the instruction.  We don't use it here, but we will use
> read_pkru() in the next patch.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
