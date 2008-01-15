Date: Tue, 15 Jan 2008 19:49:25 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/5] /proc/zoneinfo enhancement
In-Reply-To: <20080115104406.14ab0da7@lxorguk.ukuu.org.uk>
References: <20080115100233.117E.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080115104406.14ab0da7@lxorguk.ukuu.org.uk>
Message-Id: <20080115194837.11A0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi alan

> > show new member of zone struct by /proc/zoneinfo.
> > 
> > Signed-off-by: Marcelo Tosatti <marcelo@kvack.org>
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Minor NAK - Please put new fields at the end - it makes it less likely to
> break badly written tools.

Oh I see.
I applied your opinion at next post.

Thanks!


- kosaki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
