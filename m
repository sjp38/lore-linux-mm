Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 632DF6B0071
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 10:07:46 -0400 (EDT)
Date: Fri, 22 Oct 2010 09:06:48 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
In-Reply-To: <20101022103620.53A9.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1010220859080.19498@router.home>
References: <alpine.DEB.2.00.1010211255570.24115@router.home> <20101022103620.53A9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Fri, 22 Oct 2010, KOSAKI Motohiro wrote:

> I think this series has the same target with Nick's per-zone shrinker.
> So, Do you dislike Nick's approach? can you please elaborate your intention?

Sorry. I have not seen Nicks approach.

The per zone approach seems to be at variance with how objects are tracked
at the slab layer. There is no per zone accounting there. So attempts to
do expiration of caches etc at that layer would not work right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
