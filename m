Date: Thu, 14 Nov 2002 21:06:44 +0000
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [patch] remove hugetlb syscalls
Message-ID: <20021114210644.GE28216@skynet.ie>
References: <20021113184555.B10889@redhat.com> <20021114203035.GF22031@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20021114203035.GF22031@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 14, 2002 at 12:30:35PM -0800, William Lee Irwin III wrote:
> The main reason I haven't considered doing this is because they already
> got in and there appears to be a user (Oracle/IA64).

Not in shipping code.  Certainly no vendor kernels that I am aware of 
have shipped these syscalls yet either, as nearly all of the developers 
find them revolting.  Not to mention that the code cleanups and bugfixes 
are still ongoing.

		-ben
-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
