Received: by py-out-1112.google.com with SMTP id f31so3656239pyh
        for <linux-mm@kvack.org>; Sat, 28 Jul 2007 07:03:49 -0700 (PDT)
Message-ID: <64bb37e0707280703u42833adbje0ca9b4a2423d6c5@mail.gmail.com>
Date: Sat, 28 Jul 2007 16:03:49 +0200
From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.23-rc1-mm1
In-Reply-To: <64bb37e0707261054j25691afnb1bbf3484af855f3@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070725040304.111550f4.akpm@linux-foundation.org>
	 <46A7411C.80202@fr.ibm.com> <200707251323.04594.lenb@kernel.org>
	 <20070725115804.5b8efe83.akpm@linux-foundation.org>
	 <64bb37e0707251213t6edcb0a5sabcf4a923c19bde7@mail.gmail.com>
	 <64bb37e0707251322w38d19814pacea61d8cf69be63@mail.gmail.com>
	 <20070725133655.849574b5.akpm@linux-foundation.org>
	 <64bb37e0707251452u6bca43b6i2618bf6e54972dbc@mail.gmail.com>
	 <20070726002543.de303fd7.akpm@linux-foundation.org>
	 <64bb37e0707261054j25691afnb1bbf3484af855f3@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Len Brown <lenb@kernel.org>, Cedric Le Goater <clg@fr.ibm.com>, linux-kernel@vger.kernel.org, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/26/07, Torsten Kaiser <just.for.lkml@googlemail.com> wrote:
> DISCONTIGMEM+SLUB:
> [   39.833272] ..MP-BIOS bug: 8254 timer not connected to IO-APIC
> [   40.016659] Kernel panic - not syncing: IO-APIC + timer doesn't
> work! Try using the 'noapic' kernel parameter
> DISCONTIGMEM+SLAB:
> Boots until it can't find / because I didn't append the correct initrd
> It also hit the MP-BIOS bug, but was not bothered by it:
> [   36.696965] ..MP-BIOS bug: 8254 timer not connected to IO-APIC
> [   36.880537] Using local APIC timer interrupts.
> [   36.932215] result 12500283
> [   36.940581] Detected 12.500 MHz APIC timer.
>
> So I think, I will postpone SPARSEMEM until -mm2, as there are seem to
> be some problems in that area (Re: 2.6.23-rc1-mm1 sparsemem_vmemamp
> fix)
>
> But maybee I will get SLUB to work. ;)

SLUB works, if I reboot (Alt+SysRq+B) from a 2.6.22-rc6-mm1 kernel.

Otherwise it will panic with IO-APIC + timer not working.

Differences in dmesg
2.6.22-rc6-mm1 has:
[    0.000000] Nvidia board detected. Ignoring ACPI timer override.
[    0.000000] If you got timer trouble try acpi_use_timer_override
and
[    0.000000] ACPI: BIOS IRQ0 pin2 override ignored.
and
[    0.000000] TSC calibrated against PM_TIMER

 23-rc1-mm1 has:
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
and
[   37.340319] ..MP-BIOS bug: 8254 timer not connected to IO-APIC

I did not need to use acpi_use_timer_override with the older kernel.

Do you need more info about my board/ BIOS/ ACPI tables?

After the warm-boot trick 2.6.23-rc1-mm1 seems stable right now...

Torsten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
