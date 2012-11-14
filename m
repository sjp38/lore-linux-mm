Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 2316A6B009E
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 18:51:21 -0500 (EST)
Message-ID: <50A42E77.8030200@linux.intel.com>
Date: Wed, 14 Nov 2012 15:51:19 -0800
From: "H. Peter Anvin" <hpa@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 00/11] Introduce huge zero page
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com> <20121114133342.cc7bcd6e.akpm@linux-foundation.org> <20121114232013.7ee42414@pyramind.ukuu.org.uk> <20121114153243.0f6d6bec.akpm@linux-foundation.org>
In-Reply-To: <20121114153243.0f6d6bec.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On 11/14/2012 03:32 PM, Andrew Morton wrote:
> 
> The current code does the latter, by freeing the page via a
> "slab"-shrinker callback.
> 
> But I do suspect that with the right combination of use/unuse and
> memory pressure, we could still get into the high-frequency scenario.
> 

There probably isn't any mechanism that doesn't end up with poor results
in some corner case... just like the vhzp variant.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
