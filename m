Date: Mon, 24 Mar 2008 11:28:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [04/14] vcompound: Core piece
In-Reply-To: <20080322205729.B317.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0803241127370.3002@schroedinger.engr.sgi.com>
References: <20080321061703.921169367@sgi.com> <20080321061724.956843984@sgi.com>
 <20080322205729.B317.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 22 Mar 2008, KOSAKI Motohiro wrote:

> > +struct page *alloc_vcompound_alloc(gfp_t flags, int order);
> 
> where exist alloc_vcompound_alloc?

Duh... alloc_vcompound is not used at this point. Typo. _alloc needs to be 
cut off.

> Hmm,
> IMHO we need vcompound documentation more for the beginner in the Documentation/ directory.
> if not, nobody understand mean of vcompound flag at /proc/vmallocinfo.


Ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
