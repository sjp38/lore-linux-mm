Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A1EE56B004D
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 07:35:22 -0500 (EST)
Received: by fxm22 with SMTP id 22so21251fxm.6
        for <linux-mm@kvack.org>; Fri, 26 Feb 2010 04:35:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100226114312.GB16335@basil.fritz.box>
References: <20100215110135.GN5723@laptop>
	 <20100220090154.GB11287@basil.fritz.box>
	 <alpine.DEB.2.00.1002240949140.26771@router.home>
	 <4B862623.5090608@cs.helsinki.fi>
	 <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1002251228140.18861@router.home>
	 <alpine.DEB.2.00.1002251315010.3501@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1002251627040.18861@router.home>
	 <4B87A62E.5030307@cs.helsinki.fi>
	 <20100226114312.GB16335@basil.fritz.box>
Date: Fri, 26 Feb 2010 14:35:24 +0200
Message-ID: <84144f021002260435l6de50c0enb3fcc0c8b45d9f20@mail.gmail.com>
Subject: Re: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 26, 2010 at 1:43 PM, Andi Kleen <andi@firstfloor.org> wrote:
> On Fri, Feb 26, 2010 at 12:45:02PM +0200, Pekka Enberg wrote:
>> Christoph Lameter kirjoitti:
>>>> kmalloc_node() in generic kernel code. =A0All that is done under
>>>> MEM_GOING_ONLINE and not MEM_ONLINE, which is why I suggest the first =
and
>>>> fourth patch in this series may not be necessary if we prevent setting=
 the
>>>> bit in the nodemask or building the zonelists until the slab nodelists=
 are
>>>> ready.
>>>
>>> That sounds good.
>>
>> Andi?
>
> Well if Christoph wants to submit a better patch that is tested and solve=
s
> the problems he can do that.

Sure.

> if he doesn't then I think my patch kit which has been tested
> is the best alternative currently.

So do you expect me to merge your patches over his objections?

                         Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
