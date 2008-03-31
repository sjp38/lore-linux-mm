Date: Sun, 30 Mar 2008 21:12:25 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH 8/8] x86_64: Support for new UV apic
Message-ID: <20080331021224.GB20619@sgi.com>
References: <20080328191216.GA16455@sgi.com> <86802c440803301622j2874ca56t51b52a54920a233b@mail.gmail.com> <86802c440803301833r2229900cw99129515822dc373@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86802c440803301833r2229900cw99129515822dc373@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> >  Did you test it on non UV_X2APIC box?
> 
> anyway the read_apic_id is totally wrong, even for your UV_X2APIC box.
> because id=apic_read(APIC_ID) will have apic_id at bits [31,24], and
> id |= __get_cpu_var(x2apic_extra_bits) is assuming that is on bits [5,0]
> 
> so you even didn't test in your UV_X2APIC box!
> 

It works fine on UV_X2APIX boxes because the double shift does
not occur. However, support for UV_X2APIC is dependent on
x2apic code that is not yet in the tree. Once the APIC
is switched into x2apic mode, the apicid is located in the LOW
bits of the apicid register, not the HIGH bits.

I have a local x2apic patch that I apply on top of the previous
patches. The local patch is an early copy of a patch that will come
from Intel. However, the other 2 apic modes work fine with the
patches that were submitted.

--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
