Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 86BB06B00AD
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 18:14:58 -0500 (EST)
Date: Wed, 14 Nov 2012 23:20:13 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v5 00/11] Introduce huge zero page
Message-ID: <20121114232013.7ee42414@pyramind.ukuu.org.uk>
In-Reply-To: <20121114133342.cc7bcd6e.akpm@linux-foundation.org>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20121114133342.cc7bcd6e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

> I'm still a bit concerned over the possibility that some workloads will
> cause a high-frequency free/alloc/memset cycle on that huge zero page. 
> We'll see how it goes...

That is easy enough to fix - we can delay the freeing by a random time or
until memory pressure is applied.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
