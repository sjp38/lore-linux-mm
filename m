Date: Tue, 6 May 2008 10:51:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mm/page_alloc.c: fix a typo
In-Reply-To: <482029E7.6070308@cn.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0805061050110.23336@schroedinger.engr.sgi.com>
References: <4820272C.4060009@cn.fujitsu.com> <482027E4.6030300@cn.fujitsu.com>
 <482029E7.6070308@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 6 May 2008, Li Zefan wrote:

> Sorry for the noise, but the signed-off was eaten. :(
> Maybe I should leave a blank line before the signed-off.

I think the | there was some developers attempt to avoid gcc generating 
too many branches. I am fine either way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
