Date: Thu, 22 Aug 2002 09:06:20 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: MM patches against 2.5.31
Message-ID: <2631076918.1030007179@[10.10.2.3]>
In-Reply-To: <1030031958.14756.479.camel@spc9.esa.lanl.gov>
References: <1030031958.14756.479.camel@spc9.esa.lanl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>, Andrew Morton <akpm@zip.com.au>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> kjournald: page allocation failure. order:0, mode:0x0

I've seen this before, but am curious how we ever passed
a gfpmask (aka mode) of 0 to __alloc_pages? Can't see anywhere
that does this?

Thanks,

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
