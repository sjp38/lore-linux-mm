Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 7B21A6B0006
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 12:33:19 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <f3c8ef05-a880-47db-86dd-156038fc7d0f@default>
Date: Mon, 8 Apr 2013 09:32:38 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: zsmalloc defrag (Was: [PATCH] mm: remove compressed copy from zram
 in-memory)
References: <<1365400862-9041-1-git-send-email-minchan@kernel.org>>
In-Reply-To: <<1365400862-9041-1-git-send-email-minchan@kernel.org>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Bob Liu <bob.liu@oracle.com>, Shuah Khan <shuah@gonehiking.org>

> From: Minchan Kim [mailto:minchan@kernel.org]
> Sent: Monday, April 08, 2013 12:01 AM
> Subject: [PATCH] mm: remove compressed copy from zram in-memory

(patch removed)

> Fragment ratio is almost same but memory consumption and compile time
> is better. I am working to add defragment function of zsmalloc.

Hi Minchan --

I would be very interested in your design thoughts on
how you plan to add defragmentation for zsmalloc.  In
particular, I am wondering if your design will also
handle the requirements for zcache (especially for
cleancache pages) and perhaps also for ramster.

In https://lkml.org/lkml/2013/3/27/501 I suggested it
would be good to work together on a common design, but
you didn't reply.  Are you thinking that zsmalloc
improvements should focus only on zram, in which case
we may -- and possibly should -- end up with a different
allocator for frontswap-based/cleancache-based compression
in zcache (and possibly zswap)?

I'm just trying to determine if I should proceed separately
with my design (with Bob Liu, who expressed interest) or if
it would be beneficial to work together.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
