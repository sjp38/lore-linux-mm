Date: Fri, 15 Aug 2008 13:09:26 +0200
From: Jean Delvare <khali@linux-fr.org>
Subject: Re: kernel BUG at arch/x86/mm/pat.c:233 in 2.6.27-rc3-git2
Message-ID: <20080815130926.620cf987@hyperion.delvare>
In-Reply-To: <20080814161852.2dce7c21@hyperion.delvare>
References: <20080814161852.2dce7c21@hyperion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-acpi@vger.kernel.org
Cc: Andi Kleen <ak@linux.intel.com>, lenb@kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Aug 2008 16:18:52 +0200, Jean Delvare wrote:
> The boot then completes, but network doesn't work. Kernel 2.6.26.1
> works fine on that machine, and I seem to recall that 2.6.27-rc2 did as
> well (but I'm not 100% sure.)

Correcting this: kernel 2.6.27-rc2 had the same problem.

> The board is an Intel D865GSA. I can provide additional information on
> request. I can also create an entry in bugzilla if needed.

-- 
Jean Delvare

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
