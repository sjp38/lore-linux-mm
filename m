Date: Mon, 14 Jul 2008 15:56:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] powerpc: hugetlb pgtable cache access cleanup
Message-Id: <20080714155659.b4fab697.akpm@linux-foundation.org>
In-Reply-To: <487B7F96.70305@linux.vnet.ibm.com>
References: <20080604112939.789444496@amd.local0.net>
	<20080604113113.648031825@amd.local0.net>
	<487B7F96.70305@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jon Tollefson <kniht@linux.vnet.ibm.com>
Cc: npiggin@suse.de, adobriyan@gmail.com, penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jul 2008 11:32:22 -0500
Jon Tollefson <kniht@linux.vnet.ibm.com> wrote:

> Cleaned up use of macro.  We now reference the pgtable_cache array directly instead of using a macro.

This clashes rather a lot with all the other hugetlb things which we
have queued.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
