Date: Mon, 03 Mar 2003 15:52:42 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH 2.5.63] Teach page_mapped about the anon flag
Message-ID: <117290000.1046728362@baldur.austin.ibm.com>
In-Reply-To: <20030303133539.6594e0b6.akpm@digeo.com>
References: <20030227025900.1205425a.akpm@digeo.com>
 <200302280822.09409.kernel@kolivas.org>
 <20030227134403.776bf2e3.akpm@digeo.com>
 <118810000.1046383273@baldur.austin.ibm.com>
 <20030227142450.1c6a6b72.akpm@digeo.com>
 <103400000.1046725581@baldur.austin.ibm.com>
 <20030303131210.36645af6.akpm@digeo.com>
 <107610000.1046726685@baldur.austin.ibm.com>
 <20030303133539.6594e0b6.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Monday, March 03, 2003 13:35:39 -0800 Andrew Morton <akpm@digeo.com>
wrote:

> We do need a patch I think.  page_mapped() is still assuming that an
> all-bits-zero atomic_t corresponds to a zero-value atomic_t.
> 
> This does appear to be true for all supported architectures, but it's a
> bit grubby.

If that's ever not true then we need extra code to initialize/rezero that
field, since we assume it's zero on alloc, and the pte_chain code also
assumes it's zero for a new page.

Dave

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
