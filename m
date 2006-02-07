Date: Tue, 7 Feb 2006 09:14:27 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] mm: implement swap prefetching
Message-Id: <20060207091427.3483c0fb.akpm@osdl.org>
In-Reply-To: <200602072154.13062.kernel@kolivas.org>
References: <200602071028.30721.kernel@kolivas.org>
	<200602071702.20233.kernel@kolivas.org>
	<43E8436F.2010909@yahoo.com.au>
	<200602072154.13062.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: nickpiggin@yahoo.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

Con Kolivas <kernel@kolivas.org> wrote:
>
>  Andrew I think I see why your G5 didn't see any benefit with swap prefetching.

No, this machine is x86 w/ 2GB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
