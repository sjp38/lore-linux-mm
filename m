Date: Sat, 10 Nov 2007 18:21:47 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [patch 2/2] x86_64: Configure stack size
Message-ID: <20071110172146.GF22277@bingen.suse.de>
References: <20071107004357.233417373@sgi.com> <20071107004710.862876902@sgi.com> <20071107191453.GC5080@shadowen.org> <200711080012.06752.ak@suse.de> <Pine.LNX.4.64.0711071639491.4640@schroedinger.engr.sgi.com> <20071109121332.7dd34777.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071109121332.7dd34777.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, ak@suse.de, apw@shadowen.org, linux-mm@kvack.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

> What else can we do?  Change all sites to do some dynamic allocation if
> (NR_CPUS >= lots), I guess.

I think that's an reasonable alternative. Perhaps push one or two into
task_struct and grab them from there, then go dynamic. Only issue
is error handling and making it look nice in the source.

> As for timing: we might as well merge it now so that 2.6.25 has at least a
> chance of running on 16384-way.

x86 is still limited to 256 virtual CPUs. What makes you think that changed?
With x2APIC from Intel it will be higher, but I haven't seen code for 
that yet.

> otoh, I doubt if anyone will actually ship an NR_CPUS=16384 kernel, so it
> isn't terribly pointful.

NR_CPUS==4096 might happen. Of course that still needs eliminating
a lot of NR_CPUS arrays and fixing up of NR_INTERRUPTS and some other
things.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
