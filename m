Date: Thu, 9 Dec 2004 03:07:34 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Plzz help me regarding HIGHMEM (PAE) confusion in Linux-2.4 ???
Message-ID: <20041209110734.GY2714@holomorphy.com>
References: <20041209105603.4725.qmail@web53908.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041209105603.4725.qmail@web53908.mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fawad Lateef <fawad_lateef@yahoo.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 09, 2004 at 02:56:03AM -0800, Fawad Lateef wrote:
> Now the kernel is using the pagetables for kmaps hav
> PGD entry for accessing starting 4GB, but how it goes
> beyond that ? 

Only %cr3 is restricted to 32-bit physical addresses. The entries in
the pgd's, pmd's, and pte's themselves are all 36-bit physical
addresses.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
