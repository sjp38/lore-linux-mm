Date: Sat, 3 May 2003 08:08:48 +0100 (BST)
From: Matt Bernstein <mb--lkml@dcs.qmul.ac.uk>
Subject: Re: 2.5.68-mm4
In-Reply-To: <20030503025307.GB1541@averell>
Message-ID: <Pine.LNX.4.55.0305030800140.1304@jester.mews>
References: <20030502020149.1ec3e54f.akpm@digeo.com> <1051905879.2166.34.camel@spc9.esa.lanl.gov>
 <20030502133405.57207c48.akpm@digeo.com> <1051908541.2166.40.camel@spc9.esa.lanl.gov>
 <20030502140508.02d13449.akpm@digeo.com> <1051910420.2166.55.camel@spc9.esa.lanl.gov>
 <Pine.LNX.4.55.0305030014130.1304@jester.mews> <20030502164159.4434e5f1.akpm@digeo.com>
 <20030503025307.GB1541@averell>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Andrew Morton <akpm@digeo.com>, elenstev@mesatop.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At 04:53 +0200 Andi Kleen wrote:
>> > 
>> > Bizarrely I have a nasty crash on modprobing e100 *without* kexec (having
>> > previously modprobed unix, af_packet and mii) and then trying to modprobe
>> > serio (which then deadlocks the machine).
>> > 
>> > 	http://www.dcs.qmul.ac.uk/~mb/oops/
>> 
>> Andi, it died in the middle of modprobe->apply_alternatives()
>
>The important part of the oops - the first lines are missing in the .png.
>
>What is the failing address? And can you send me your e100.o ?

I'm sorry I can't get to the machine now till Tuesday. I'll try to get it 
into a smaller font, or failing that a serial console if you like.

I've posted e100.{,k}o, vmlinux and System.map to the above URL. FWIW, 
they both give "c010e840 T apply_alternatives". I've also posted ".config" 
which Apache elects not to list :)

Does any of the above help?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
