Date: Tue, 6 May 2003 15:15:55 +0100 (BST)
From: Matt Bernstein <mb--lkml@dcs.qmul.ac.uk>
Subject: Re: 2.5.68-mm4
In-Reply-To: <Pine.LNX.4.55.0305030800140.1304@jester.mews>
Message-ID: <Pine.LNX.4.55.0305061511020.3237@r2-pc.dcs.qmul.ac.uk>
References: <20030502020149.1ec3e54f.akpm@digeo.com> <1051905879.2166.34.camel@spc9.esa.lanl.gov>
 <20030502133405.57207c48.akpm@digeo.com> <1051908541.2166.40.camel@spc9.esa.lanl.gov>
 <20030502140508.02d13449.akpm@digeo.com> <1051910420.2166.55.camel@spc9.esa.lanl.gov>
 <Pine.LNX.4.55.0305030014130.1304@jester.mews> <20030502164159.4434e5f1.akpm@digeo.com>
 <20030503025307.GB1541@averell> <Pine.LNX.4.55.0305030800140.1304@jester.mews>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
Cc: Andi Kleen <ak@muc.de>, Andrew Morton <akpm@digeo.com>, elenstev@mesatop.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On May 3 Matt Bernstein wrote:

>>> > Bizarrely I have a nasty crash on modprobing e100 *without* kexec (having
>>> > previously modprobed unix, af_packet and mii) and then trying to modprobe
>>> > serio (which then deadlocks the machine).
>>> > 
>>> > 	http://www.dcs.qmul.ac.uk/~mb/oops/
>>> 
>>> Andi, it died in the middle of modprobe->apply_alternatives()
>>
>>The important part of the oops - the first lines are missing in the .png.
>>
>>What is the failing address? And can you send me your e100.o ?
>
>I'm sorry I can't get to the machine now till Tuesday. I'll try to get it 
>into a smaller font, or failing that a serial console if you like.

I've now built 2.5.69-mm1 and it gives a very similar oops--and it wasn't 
related to e100; it would oops on the third modprobe!

So, I built a load of my modules into the monolith: leaving just uhci and
e100, and now the first modprobe oopses and the second deadlocks..

However, the trace is a little deeper this time:
	http://www.dcs.qmul.ac.uk/~mb/oops/oops2small.jpeg

Is this helpful?

Matt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
