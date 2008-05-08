Date: Thu, 08 May 2008 09:08:00 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm/page_alloc.c: fix a typo
In-Reply-To: <Pine.LNX.4.64.0805061050110.23336@schroedinger.engr.sgi.com>
References: <482029E7.6070308@cn.fujitsu.com> <Pine.LNX.4.64.0805061050110.23336@schroedinger.engr.sgi.com>
Message-Id: <20080508090647.4A7B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > Sorry for the noise, but the signed-off was eaten. :(
> > Maybe I should leave a blank line before the signed-off.
> 
> I think the | there was some developers attempt to avoid gcc generating 
> too many branches. I am fine either way.

Agreed.
but it is not normal conding style.
comment adding is better, IMHO.

at first, I think typo too.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
