Date: Fri, 4 Apr 2003 10:18:23 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] tweaks for page_convert_anon
Message-Id: <20030404101823.2a63bb02.akpm@digeo.com>
In-Reply-To: <Pine.LNX.4.44.0304041735150.1980-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0304041735150.1980-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: dmccr@us.ibm.com, zaitcev@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> wrote:
>
> Also, page_convert_anon remember pte_unmap after successful find_pte.

gack.

OK, thanks.  I've dropped my current rollup against 2.5.66 at

http://www.zip.com.au/~akpm/linux/patches/2.5/hd.patch.gz
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
