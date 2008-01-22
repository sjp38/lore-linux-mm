From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86
Date: Tue, 22 Jan 2008 14:33:29 +0100
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie> <p73hcha9vc5.fsf@bingen.suse.de> <20080119160743.GA8352@csn.ul.ie>
In-Reply-To: <20080119160743.GA8352@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801221433.29771.andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

> Without SRAT support, a compile-error occurs because ACPI table parsing
> functions are only available in x86-64. This patch also adds no-op stubs
> and prints a warning message. What likely needs to be done is sharing
> the table parsing functions between 32 and 64 bit if they are
> compatible.

I'm a little confused by your patch.

i386 already has srat parsing code (just written in a horrible hackish way); 
but it exists arch/x86/kernel/srat_32.c

That one tended to explode on Opteron, but apparently worked on some 
Summit boxes.

You're saying you want to remove that code and replace it based on something
based on the drivers/acpi/numa.c parsing code? While that's in theory
a worthy goal it will not actually help all that much because numa.c only
does some high level parsing, but nothing of the actual low level work
of setting things up.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
