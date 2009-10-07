Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B3A816B004F
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 10:26:25 -0400 (EDT)
Message-Id: <4ACCC12E020000780001882B@vpn.id2.novell.com>
Date: Wed, 07 Oct 2009 15:26:22 +0100
From: "Jan Beulich" <JBeulich@novell.com>
Subject: Re: [PATCH] adjust gfp mask passed on nested vmalloc()
	 invocation  (v2)
References: <4ACCA98202000078000187DF@vpn.id2.novell.com>
 <Pine.LNX.4.64.0910071451090.4695@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0910071451090.4695@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>>> Hugh Dickins <hugh.dickins@tiscali.co.uk> 07.10.09 15:55 >>>
>On Wed, 7 Oct 2009, Jan Beulich wrote:
>
>> - avoid wasting more precious resources (DMA or DMA32 pools), when
>>   being called through vmalloc_32{,_user}()
>> - explicitly allow using high memory here even if the outer allocation
>>   request doesn't allow it, unless is collides with __GFP_ZERO
>                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>                            that's no longer an issue in the patch

Oops. Will send out a corrected version in a second.

Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
