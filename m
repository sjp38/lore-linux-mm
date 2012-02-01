Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 595AA6B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 09:40:12 -0500 (EST)
Date: Wed, 1 Feb 2012 08:40:09 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] move vm tools from Documentation/vm/ to tools/
In-Reply-To: <20120201083032.GA6774@localhost>
Message-ID: <alpine.DEB.2.00.1202010839540.28991@router.home>
References: <20120201063420.GA10204@darkstar.nay.redhat.com> <CAOJsxLGVS3bK=hiKJu4NwTv-Nf8TCSAEL4reSZoY4=44hPt8rA@mail.gmail.com> <4F28EC9D.7000907@redhat.com> <20120201083032.GA6774@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Dave Young <dyoung@redhat.com>, Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, 1 Feb 2012, Wu Fengguang wrote:

> > BTW, I think tools/slub/slabinfo.c should be included in tools/vm/ as
> > well, will move it in v2 patch
>
> CC Christoph. Maybe not a big deal since it's already under tools/.

Sure. You have my blessing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
