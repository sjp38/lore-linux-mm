Date: Mon, 31 Mar 2008 14:33:38 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC 8/8] x86_64: Support for new UV apic
Message-ID: <20080331123338.GA14636@elte.hu>
References: <20080324182122.GA28327@sgi.com> <87abknhzhd.fsf@basil.nowhere.org> <20080325175657.GA6262@sgi.com> <20080326073823.GD3442@elte.hu> <86802c440803301323q5c4bd4f4k1f9bdc1d6b1a0a7b@mail.gmail.com> <20080330210356.GA13383@sgi.com> <20080330211848.GA29105@one.firstfloor.org> <86802c440803301629g6d1b896o27e12ef3c84ded2c@mail.gmail.com> <20080331021821.GC20619@sgi.com> <86802c440803301920o47335876yac12a5a09d1a8cc9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86802c440803301920o47335876yac12a5a09d1a8cc9@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: Jack Steiner <steiner@sgi.com>, Andi Kleen <andi@firstfloor.org>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Yinghai Lu <yhlu.kernel@gmail.com> wrote:

> On Sun, Mar 30, 2008 at 7:18 PM, Jack Steiner <steiner@sgi.com> wrote:
> > >
> >  > if the calling path like GET_APIC_ID is keeping checking if it is 
> >  > UV box after boot time, that may not good.
> >  >
> >  > don't need make other hundreds of machine keep running the code 
> >  > only for several big box all the time.
> >  >
> >  > YH
> >
> >
> >  I added trace code to see how often GET_APIC_ID() is called. For my 
> >  8p AMD box, the function is called 6 times per cpu during boot. I 
> >  have not seen any other calls to the function after early boot 
> >  although I'm they occur under some circumstances.
> 
> then it is ok.

yes - and even if it were called more frequently, having generic code 
and having the possibility of an as generic as possible kernel image 
(and kernel rpms) is still a very important feature. In that sense 
subarch support is actively harmful and we are trying to move away from 
that model.

It is very nice that Jack has managed to make UV a generic platform 
instead of a subarch - and i'd encourage all future PC platform 
extensions to work via that model. The status of current PC 
subarchitectures is the following:

 - mach-visws: obsolete. We could drop it today - it's been years since 
                         i saw real VISWS bugreports.

 - mach-voyager: obsolete.

 - mach-es7000: on the way out - latest ES7000's are generic.

 - mach-rdc321x: it's being de-sub-architectured. It's about one patch 
                 away from becoming a non-subarch.

so we are just a few patches and a few well-directed voltage spikes away 
from being able to remove the subarch complication from x86 altogether 
;-)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
