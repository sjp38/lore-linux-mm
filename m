Date: Wed, 25 Jan 2006 16:52:36 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH/RFC] Shared page tables
Message-ID: <F6EF7D7093D441B7655A8755@[10.1.1.4]>
In-Reply-To: <200601251648.58670.raybry@mpdtxmail.amd.com>
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
 <200601241743.28889.raybry@mpdtxmail.amd.com>
 <07A9BE6C2CADACD27B259191@[10.1.1.4]>
 <200601251648.58670.raybry@mpdtxmail.amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@mpdtxmail.amd.com>
Cc: Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--On Wednesday, January 25, 2006 16:48:58 -0600 Ray Bryant
<raybry@mpdtxmail.amd.com> wrote:

> Empirically, at least on Opteron, it looks like the first page of pte's
> is  never shared, even if the alignment of the mapped region is correct
> (i. e. a  2MB boundary for X86_64).    Is that what you expected?

If the region is aligned it should be shared.  I'll investigate.

Thanks,
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
