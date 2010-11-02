Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 648C56B016C
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 04:57:56 -0400 (EDT)
Received: by vws18 with SMTP id 18so4831826vws.14
        for <linux-mm@kvack.org>; Tue, 02 Nov 2010 01:57:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTinPTrc6FpBRTZbDcsOdwpRUayQuE+2K8U8yPorz@mail.gmail.com>
References: <AANLkTinPTrc6FpBRTZbDcsOdwpRUayQuE+2K8U8yPorz@mail.gmail.com>
Date: Tue, 2 Nov 2010 10:57:51 +0200
Message-ID: <AANLkTi=tFRb6FYJ0Zi0ybZOr=Wt8_nAP1YO=4Cipg4wE@mail.gmail.com>
Subject: Re: Where is the SLAM (a mutable slab allocator) development happening?
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: sedat.dilek@gmail.com
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 2, 2010 at 9:49 AM, Sedat Dilek <sedat.dilek@googlemail.com> wrote:
> Hi,
>
> while looking through the program of LPC, I have seen a proposal for a
> talk called "SLAM: a mutable slab allocator" [1].
>
> As there was no reference given to the code-base, I went searching on
> the Wild Wild Web and found a thread called "[UnifiedV4 00/16] The
> Unified slab allocator (V4)" posted to LKML.
> It looks to me that these patches went to Pekka's slab/for-next GIT-branch [2].
> I am not sure if this is "SLAM".

I've never heard of such a beast. Lets ask David?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
