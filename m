Date: Mon, 08 Jul 2002 23:15:52 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <1221230287.1026170151@[10.10.2.3]>
In-Reply-To: <3D2A7466.AD867DA7@zip.com.au>
References: <3D2A7466.AD867DA7@zip.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Don't tell me those NUMAQ's are using IDE ;)

No, that's one level of pain I don't have to deal with ;-)

Now switched fibrechannel SANs on a machine that really needs
NUMA aware multipath IO is more likely to be a problem, on 
the other hand ... but I can live without that for now ...

> But seriously, what's the problem?  We really do need the big
> boxes to be able to test 2.5 right now, and any blockage needs
> to be cleared away.

You really want the current list? The whole of our team is 
shifting focus to 2.5, which'll make life more interesting ;-)

wli might care to elaborate on 2 & 3, since I think he helped
them identify / fix (helped maybe meaning did).

1. Irqbalance doesn't like clustered apic mode (have hack)
2. Using ioremap fairly early catches cpu_online_map set to 0
   for some reason (have hack).
3. Something to do with BIO that I'll let Bill explain, but I
   am given to believe it's well known (have hack).

After this, one of our team got one of the boxes booted today
for the first time on a recent 2.5 kernel, but I don't have any 
numbers from it yet.

4. Starfire ethernet driver doesn't seem to want to compile in
   (crc32_le in set_rx_mode?) Can't recall the exact error, will
   recreate tommorow, may well work as a module. 
5. Compiler errors that I haven't really looked at but am guessing
   may be due to me using an old compiler / tools (Redhat 6.2)?

/tmp/cca8ibx8.s: Assembler messages:
/tmp/cca8ibx8.s:255: Error: suffix or operands invalid for `lcall'
  gcc -Wp,-MD,./.setup.o.d -D__ASSEMBLY__ -D__KERNEL__ -I/home/mbligh/linux-2.5.25/include -nostdinc -iwithprefix include  -traditional -DSVGA_MODE=NORMAL_VGA  -D__BIG_KERNEL__  -c -o setup.o setup.S
make[1]: *** [bootsect.o] Error 1
make[1]: *** Waiting for unfinished jobs....
/tmp/ccn0yhUe.s: Assembler messages:
/tmp/ccn0yhUe.s:1292: Error: suffix or operands invalid for `lcall'
make[1]: *** [setup.o] Error 1
make[1]: Leaving directory `/home/mbligh/linux-2.5.25/arch/i386/boot'
make: *** [install] Error 2

At that point, I decided to wait until tommorow as I really need
to switch machines, disks, distributions, and reinstall ;-) But
then I need to do a few more things ...

6. Get someone to port forward the ia32 discontigmem support, test
   and submit.
7. Port forward the TSC disable changes.
8. Port forward the remote quad timer disable changes.
9. Port forward the pci-bridge remap hack that I'm too ashamed to
   publish.

Then I might get some numbers out of her ;-) Comparing 2.4 to 2.5
will be most interesting ...

In the meantime I'll get you some numbers from an 8 way SMP box,
which should be much simpler to do.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
