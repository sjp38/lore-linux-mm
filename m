Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DE01E6B0047
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 06:25:27 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so755329yxh.26
        for <linux-mm@kvack.org>; Tue, 21 Apr 2009 03:25:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090421084519.GE12713@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie>
	 <1240266011-11140-13-git-send-email-mel@csn.ul.ie>
	 <1240299982.771.48.camel@penberg-laptop>
	 <20090421084519.GE12713@csn.ul.ie>
Date: Tue, 21 Apr 2009 13:25:50 +0300
Message-ID: <84144f020904210325v49b0321sfea6b7d9fc426237@mail.gmail.com>
Subject: Re: [PATCH 12/25] Remove a branch by assuming __GFP_HIGH ==
	ALLOC_HIGH
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Mel,

On Tue, Apr 21, 2009 at 11:45 AM, Mel Gorman <mel@csn.ul.ie> wrote:
>> > @@ -1639,8 +1639,8 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
>> > =A0 =A0 =A0* policy or is asking for __GFP_HIGH memory. =A0GFP_ATOMIC =
requests will
>> > =A0 =A0 =A0* set both ALLOC_HARDER (!wait) and ALLOC_HIGH (__GFP_HIGH)=
.
>> > =A0 =A0 =A0*/
>> > - =A0 if (gfp_mask & __GFP_HIGH)
>> > - =A0 =A0 =A0 =A0 =A0 alloc_flags |=3D ALLOC_HIGH;
>> > + =A0 VM_BUG_ON(__GFP_HIGH !=3D ALLOC_HIGH);
>> > + =A0 alloc_flags |=3D (gfp_mask & __GFP_HIGH);
>>
>> Shouldn't you then also change ALLOC_HIGH to use __GFP_HIGH or at least
>> add a comment somewhere?
>
> That might break in weird ways if __GFP_HIGH changes in value then. I
> can add a comment though
>
> /*
> =A0* __GFP_HIGH is assumed to be the same as ALLOC_HIGH to save a branch.
> =A0* Check for DEBUG_VM that the assumption is still correct. It cannot b=
e
> =A0* checked at compile-time due to casting
> =A0*/
>
> ?

I'm perfectly fine with something like that.

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

                                      Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
