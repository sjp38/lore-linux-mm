From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH]: Clean up of __alloc_pages
Date: Mon, 7 Nov 2005 04:42:58 +0100
References: <20051028183326.A28611@unix-os.sc.intel.com> <20051106124944.0b2ccca1.pj@sgi.com> <436EC2AF.4020202@yahoo.com.au>
In-Reply-To: <436EC2AF.4020202@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511070442.58876.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Paul Jackson <pj@sgi.com>, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Monday 07 November 2005 03:57, Nick Piggin wrote:

>
> I don't think so because if the cpuset can be freed, then its page
> might be unmapped from the kernel address space if use-after-free
> debugging is turned on. And this is a use after free :)

RCU could be used to avoid that. Just only free it in a RCU callback.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
