Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 105BF6B0068
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 11:34:30 -0400 (EDT)
Message-ID: <5069B804.6040902@linux.intel.com>
Date: Mon, 01 Oct 2012 08:34:28 -0700
From: "H. Peter Anvin" <hpa@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Virtual huge zero page
References: <1348875441-19561-1-git-send-email-kirill.shutemov@linux.intel.com> <20120929134811.GC26989@redhat.com>
In-Reply-To: <20120929134811.GC26989@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org

On 09/29/2012 06:48 AM, Andrea Arcangeli wrote:
> 
> There would be a small cache benefit here... but even then some first
> level caches are virtually indexed IIRC (always physically tagged to
> avoid the software to notice) and virtually indexed ones won't get any
> benefit.
> 

Not quite.  The virtual indexing is limited to a few bits (e.g. three
bits on K8); the right way to deal with that is to color the zeropage,
both the regular one and the virtual one (the virtual one would circle
through all the colors repeatedly.)

The cache difference, therefore, is *huge*.

> I guess it won't make a whole lot of difference but my preference is
> for the previous implementation that always guaranteed huge TLB
> entries whenever possible. Said that I'm fine either ways so if
> somebody has strong reasons for wanting this one, I'd like to hear
> about it.

It's a performance tradeoff, and it can, and should, be measured.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
