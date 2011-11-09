Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 510DF6B0069
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 14:19:48 -0500 (EST)
Received: by vws16 with SMTP id 16so2352098vws.14
        for <linux-mm@kvack.org>; Wed, 09 Nov 2011 11:19:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1111031440130.31612@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1110182207500.5907@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1111031440130.31612@chino.kir.corp.google.com>
Date: Wed, 9 Nov 2011 21:19:46 +0200
Message-ID: <CAOJsxLGOhW3tLTCZZw3VKoxd4Cg8ZN66ACj1vW3yQAFRenm3-A@mail.gmail.com>
Subject: Re: [patch 1/2] slab: rename slab_break_gfp_order to slab_max_order
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@gentwo.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 18 Oct 2011, David Rientjes wrote:
>> slab_break_gfp_order is more appropriately named slab_max_order since it
>> enforces the maximum order size of slabs as long as a single object will
>> still fit.
>>
>> Also rename BREAK_GFP_ORDER_{LO,HI} accordingly.

On Thu, Nov 3, 2011 at 11:40 PM, David Rientjes <rientjes@google.com> wrote=
:
> Ping on these two patches? =A0I don't see them in slab/next.

The patches seem reasonable to me. Christoph?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
