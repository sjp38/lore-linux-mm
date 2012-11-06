Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id B81286B004D
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 17:45:42 -0500 (EST)
Message-ID: <509993A5.2000605@redhat.com>
Date: Tue, 06 Nov 2012 17:48:05 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/16] mm: use vm_unmapped_area() in hugetlbfs on i386
 architecture
References: <1352155633-8648-1-git-send-email-walken@google.com> <1352155633-8648-10-git-send-email-walken@google.com> <20121106143826.dc3b960c.akpm@linux-foundation.org>
In-Reply-To: <20121106143826.dc3b960c.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, x86@kernel.org, William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On 11/06/2012 05:38 PM, Andrew Morton wrote:
> On Mon,  5 Nov 2012 14:47:06 -0800
> Michel Lespinasse <walken@google.com> wrote:
>
>> Update the i386 hugetlb_get_unmapped_area function to make use of
>> vm_unmapped_area() instead of implementing a brute force search.
>
> The x86_64 coloring "fix" wasn't copied into i386?

Only certain 64 bit AMD CPUs have that issue at all.

On x86, page coloring is really not much of an issue.

All the x86-64 patch does is make the x86-64 page
coloring code behave the same way page coloring
does on MIPS, SPARC, ARM, PA-RISC and others...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
