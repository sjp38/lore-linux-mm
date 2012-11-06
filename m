Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id AF5416B005A
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 17:38:27 -0500 (EST)
Date: Tue, 6 Nov 2012 14:38:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 09/16] mm: use vm_unmapped_area() in hugetlbfs on i386
 architecture
Message-Id: <20121106143826.dc3b960c.akpm@linux-foundation.org>
In-Reply-To: <1352155633-8648-10-git-send-email-walken@google.com>
References: <1352155633-8648-1-git-send-email-walken@google.com>
	<1352155633-8648-10-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, x86@kernel.org, William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On Mon,  5 Nov 2012 14:47:06 -0800
Michel Lespinasse <walken@google.com> wrote:

> Update the i386 hugetlb_get_unmapped_area function to make use of
> vm_unmapped_area() instead of implementing a brute force search.

The x86_64 coloring "fix" wasn't copied into i386?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
