Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id C5B666B0096
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 14:05:05 -0400 (EDT)
Date: Mon, 1 Oct 2012 20:05:00 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/3] Virtual huge zero page
Message-ID: <20121001180500.GF18051@redhat.com>
References: <1348875441-19561-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120929134811.GC26989@redhat.com>
 <5069B804.6040902@linux.intel.com>
 <20121001163118.GC18051@redhat.com>
 <5069CCF9.7040309@linux.intel.com>
 <20121001172624.GD18051@redhat.com>
 <5069D3D8.9070805@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5069D3D8.9070805@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org

On Mon, Oct 01, 2012 at 10:33:12AM -0700, H. Peter Anvin wrote:
> ... and I think it would be worthwhile to know which effect dominates
> (or neither, in which case it doesn't matter).
> 
> Overall, I'm okay with either as long as we don't lock down 2 MB when
> there isn't a huge zero page in use.

Same here.

I agree the cmpxchg idea to free the 2M zero page, was a very nice
addition to the physical zero page patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
