From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH/RFC] Shared page tables
Date: Tue, 24 Jan 2006 02:11:58 +0100
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]> <200601240139.46751.ak@suse.de> <08A96D993E5CB2984F6F448A@[10.1.1.4]>
In-Reply-To: <08A96D993E5CB2984F6F448A@[10.1.1.4]>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200601240211.59171.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Ray Bryant <raybry@mpdtxmail.amd.com>, Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 24 January 2006 01:51, Dave McCracken wrote:
>  Most of the large OLTP applications use fixed address
> mapping for their large shared regions.

Really? That sounds like a quite bad idea because it can easily break
if something changes in the way virtual memory is laid out (which
has happened - e.g. movement to 4level page tables on x86-64 and now
randomized mmaps) 

I don't think we should encourage such unportable behaviour.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
