Message-ID: <3AB6410D.74BFBE67@amphus.com>
Date: Mon, 19 Mar 2001 09:25:33 -0800
From: Andrew Stanley-Jones <asj@amphus.com>
MIME-Version: 1.0
Subject: 2.4.2 kernel weirdness
Content-Type: multipart/mixed;
 boundary="------------8C66712E00934968BF8EC49F"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Jim Bailey <jbailey@amphus.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------8C66712E00934968BF8EC49F
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

Hi,

I wasn't confident of the SDRAM setup on an embedded 486 machine, so I
wrote a user space program to write and read mem to make sure everything
was ok.  Well when the program runs almost instantly it generates a oops
(with eip in schedual).  Assuming SDRAM setup was bad I added various
checks in boot up to read and write mem.  They didn't show any problems,
I can read and write all I like, the mem works.

Attached is mem_test.c, in the 486 with 64 megs of mem testing with 5
megs (mem_test 5242880) crashes instanly.  With 4.5 megs (mem_test
4718592) it crashes on exit with varouis kernel bug/panic messages. =

With 4 megs everything is fine.

Here's the full logs for boot up from chip reset till Oops:

Hello world!!
RAM Setup, almost done with ASM
Done with ASM, going to C
Reached intel_main()
<6>Finding PCI confiuration type...
PCI: Using configuration type 1
<6>Scanning PCI bus...<6>done
<6>Enabling cache...<6>done.
<6>Allocating PCI resources...COMPUTE_ALLOCATE: do IO
compute_allocate_io: base 0xf000
DEVIO: Bus 0x0, devfn 0x88, reg 0x0: iosize 0x20
-->set base to 0xf000
DEVIO: Bus 0x0, devfn 0x91, reg 0x1: iosize 0x100
-->set base to 0xf020
DEVIO: Bus 0x0, devfn 0xa0, reg 0x0: iosize 0x100
-->set base to 0xf120
BUS 0: set iolimit to 0xffff
COMPUTE_ALLOCATE: do MEM
compute_allocate_mem: base 0x10000000
DEVMEM: Bus 0x0, devfn 0x88, reg 0x1: memsize 0x1000
-->set base to 0x10000000
DEVMEM: Bus 0x0, devfn 0x90, reg 0x0: memsize 0x1000000
-->set base to 0x11000000
DEVMEM: Bus 0x0, devfn 0x91, reg 0x0: memsize 0x1000
-->set base to 0x12000000
DEVMEM: Bus 0x0, devfn 0xa0, reg 0x1: memsize 0x1000
-->set base to 0x12001000
BUS 0: set memlimit to 0x120fffff
COMPUTE_ALLOCATE: do PREFMEM
Compute_allocate_prefmem: base 0x12100000
BUS 0: set prefmemlimit to 0x120fffff
ASSIGN RESOURCES, bus 0
Bus 0x0 devfn 0x88 reg 0x0 base to 0xf001
Bus 0x0 devfn 0x88 reg 0x1 base to 0x10000000
Bus 0x0 devfn 0x90 reg 0x0 base to 0x11000000
Bus 0x0 devfn 0x91 reg 0x0 base to 0x12000000
Bus 0x0 devfn 0x91 reg 0x1 base to 0xf021
Bus 0x0 devfn 0xa0 reg 0x0 base to 0xf121
Bus 0x0 devfn 0xa0 reg 0x1 base to 0x12001000
DEV Set command bus 0x0 devfn 0x0 to 0x4
DEV Set command bus 0x0 devfn 0x88 to 0x3
DEV Set command bus 0x0 devfn 0x90 to 0x2
DEV Set command bus 0x0 devfn 0x91 to 0x3
DEV Set command bus 0x0 devfn 0xa0 to 0x3
<6>done.
<6>Enabling extended BIOS access...<6>done.
<6>Zeroing IRQ settings...<6>done.
Bus: 0x0 Devfn: 0x0 [0x1022/0x3000] slot: 0 CMD: 0006
Bus: 0x0 Devfn: 0x88 [0x1022/0x2000] slot: 17 pin: 1 irq: 11
Bus: 0x0 Devfn: 0x88 [0x1022/0x2000] slot: 17 CMD: 0007
Bus: 0x0 Devfn: 0x90 [0x10ea/0x5000] slot: 18 pin: 1 irq: 9
Bus: 0x0 Devfn: 0x90 [0x10ea/0x5000] slot: 18 CMD: 0006
Bus: 0x0 Devfn: 0x91 [0x10ea/0x5050] slot: 18 pin: 1 irq: 9
Bus: 0x0 Devfn: 0x91 [0x10ea/0x5050] slot: 18 CMD: 0007
Bus: 0x0 Devfn: 0xa0 [0x1317/0x0985] slot: 20 pin: 1 irq: 11
Bus: 0x0 Devfn: 0xa0 [0x1317/0x0985] slot: 20 CMD: 0007
<6>Enabling interrupts...<6>done.
<6>Starting IDE
+IdentifyATA(00003bf8)
 Flags=3D008a, CHS=3D234.2.32
 SerialNumber=3D''
 FirmwareVersion=3D''
 Model=3D''
<6>Starting FAT
MB:part[0]: bootid=3Dx00 chs=3D1.1.0
          : sysid=3Dx06 echs=3D1.32.64 startsec=3D32 size=3D4128
MB:part[1]: bootid=3Dx00 chs=3D0.1.65
          : sysid=3Dx83 echs=3D1.96.129 startsec=3D4160 size=3D20544
MB:part[2]: bootid=3Dx00 chs=3D0.65.130
          : sysid=3Dx83 echs=3D1.96.233 startsec=3D24704 size=3D6656
MB:part[3]: bootid=3Dx00 chs=3D0.0.0
          : sysid=3Dx00 echs=3D0.0.0 startsec=3D0 size=3D0
MB:sig=3Dxaa55
FAT Boot: jmp=3Deb.3c.90 name=3D'mkdosfs' bps=3D512 spc=3D4 rsec=3D1
        : fats=3D2 dirs=3D512 sectors=3D4128 mediaid=3Dxf8
        : spf=3D4 spt=3D32 heads=3D2 hsec=3D0 tsec=3D0
ReadFBS: Bases: partofs=3D32 fatofs=3D33 dirofs=3D41 fileofs=3D73
       : fatsectors=3D4128 fatclusters=3D1013
FatDir: at=3Dx20=3D     A --- 'VMLINUX .BIN'
      : case=3D00 cre=3D2a6f.54f7.00 acc=3D0000 ch=3D0 t=3D2a6f.54f7 sc=3D=
377
size=3D768000
Loading file: done!
Read: VMLINUX.BIN (768000 bytes)
Read: Success
Jumping to linuxbiosmain()...

Welcome to start32, the open sourced starter.
This space will eventually hold more diagnostic information.

January 2000, James Hendricks, Dale Webster, and Ron Minnich.
Version 0.1

Linux version 2.4.2ikd1 (asj@komeera) (gcc version 2.95.2 19991024
(release)) #34 Thu Mar 15 10:31:25 PST 2001
BIOS-provided physical RAM map:
 BIOS-e801: 000000000009f000 @ 0000000000000000 (usable)
 BIOS-e801: 0000000003e00000 @ 0000000000100000 (usable)
On node 0 totalpages: 16128
zone(0): 4096 pages.
zone(1): 12032 pages.
zone(2): 0 pages.
Kernel command line: root=3D/dev/hda2 console=3DttyS1,38400 ide0=3Dreset
ide_setup: ide0=3Dreset
Initializing CPU#0
Calibrating delay loop... 50.07 BogoMIPS
Memory: 61904k/64512k available (639k kernel code, 2220k reserved, 206k
data, 56k init, 0k highmem)
Checking if this processor honours the WP bit even in supervisor mode...
Ok.
Dentry-cache hash table entries: 8192 (order: 4, 65536 bytes)
Buffer-cache hash table entries: 1024 (order: 0, 4096 bytes)
Page-cache hash table entries: 16384 (order: 4, 65536 bytes)
Inode-cache hash table entries: 4096 (order: 3, 32768 bytes)
CPU: Before vendor init, caps: 00000001 00000000 00000000, vendor =3D 2
CPU: After vendor init, caps: 00000001 00000000 00000000 00000000
CPU: After generic, caps: 00000001 00000000 00000000 00000000
CPU: Common caps: 00000001 00000000 00000000 00000000
CPU: AMD 486 DX/4-WB stepping 04
Checking 'hlt' instruction... OK.
Checking for popad bug... OK.
POSIX conformance testing by UNIFIX
PCI: Using configuration type 1
PCI: Probing PCI hardware
PCI: Scanning for ghost devices on bus 0
PCI: IRQ init
PCI: IRQ fixup
PCI: Allocating resources
PCI: Resource 0000f000-0000f01f (f=3D101, d=3D0, p=3D0)
PCI: Resource 10000000-1000001f (f=3D200, d=3D0, p=3D0)
PCI: Resource 11000000-11ffffff (f=3D200, d=3D0, p=3D0)
PCI: Resource 12000000-12000fff (f=3D200, d=3D0, p=3D0)
PCI: Resource 0000f000-0000f0ff (f=3D101, d=3D0, p=3D0)
PCI: Cannot allocate resource region 1 of device 00:12.1
PCI: Resource 0000f100-0000f1ff (f=3D101, d=3D0, p=3D0)
PCI: Resource 12001000-120013ff (f=3D200, d=3D0, p=3D0)
  got res[1000:10ff] for resource 1 of PCI device 10ea:5050
Linux NET4.0 for Linux 2.4
Based upon Swansea University Computer Society NET3.039
Starting kswapd v1.8
pty: 256 Unix98 ptys configured
block: queued sectors max/low 41077kB/13692kB, 128 slots per queue
RAMDISK driver initialized: 16 RAM disks of 2048K size 1024 blocksize
Uniform Multi-Platform E-IDE driver Revision: 6.31
ide: Assuming 33MHz system bus speed for PIO modes; override with
idebus=3Dxx
hda: SanDisk SDCFB-16, ATA DISK drive
ide0: reset
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
hda: 31360 sectors (16 MB) w/1KiB Cache, CHS=3D490/2/32
Partition check:
 hda: hda1 hda2 hda3
Serial driver version 5.02 (2000-08-09) with DETECT_IRQ enabled
=FFttyS01 at 0x02f8 (irq =3D 0) is a 16550A
Linux Tulip driver version 0.9.13a (January 20, 2001)
PCI: Setting latency timer of device 00:14.0 to 64
eth0: ADMtek Comet rev 17 at 0xf100, 00:C0:26:A0:10:D1, IRQ 11.
NET4: Linux TCP/IP 1.0 for NET4.0
IP Protocols: ICMP, UDP, TCP
IP: routing cache hash table of 512 buckets, 4Kbytes
TCP: Hash tables configured (established 4096 bind 4096)
 hda: hda1 hda2 hda3
 hda: hda1 hda2 hda3
VFS: Mounted root (ext2 filesystem) readonly.
Freeing unused kernel memory: 56k freed
INIT: version 2.76 booting
/root/elan_cfg/elan_pci.o: /root/elan_cfg/elan_pci.o: No such file or
directory

Loading modules: =


Checking all file systems...

fsck failed.  Please repair manually.

CONTROL-D will exit from this shell and continue system startup.

EXT2-fs warning: mounting unchecked fs, running e2fsck is recommended
Configuring and Starting Network...lo =

Local time (GMT): Wed Jun  2 00:00:12 UTC 1971

Configuring serial ports...LSR safety check engaged!
Cannot set seriaINIT: Entering runlevel: 2
Starting base networking daemons: portmap inetd.
Starting periodic command scheduler: cron.

Lem -Linux Embedded- V0.61
elan login: asj
sh-2.04$ ./mem_test 5242880
Doing Malloc
Doing Write pattern: 0xaaaaaaaa
Unable to handle kernel paging request at virtual address aaaaaab2
 printing eip:
c012dba1 =

*pde =3D 00000000
Oops: 0000
CPU:    0
EIP:    0010:[<c012dba1>]
EFLAGS: 00010213
eax: aaaaaaaa   ebx: c3c32000   ecx: 00000002   edx: 00000000
esi: fffffff7   edi: 080789a0   ebp: 00000020   esp: c3c33fac
ds: 0018   es: 0018   ss: 0018
Process mem_test (pid: 64, stackpage=3Dc3c33000)
Stack: c012d122 c3c32000 bfffd7cc 080789a0 bfffd65c c0108e4b 00000002
bfffd7cc =

       00000020 bfffd7cc 080789a0 bfffd65c 00000004 0000002b 0000002b
00000004 =

       08066844 00000023 00000293 bfffd62c 0000002b =

Call Trace: [<c012d122>] [<c0108e4b>] =


Code: 8b 14 88 85 d2 74 03 ff 42 14 89 d0 c3 89 f6 8b 4c 24 04 ff =

Unable to handle kernel paging request at virtual address aaaaab2e
 printing eip:
c0114fb4
*pde =3D 00000000
Oops: 0000
CPU:    0
EIP:    0010:[<c0114fb4>]
EFLAGS: 00010287
eax: 00000000   ebx: aaaaaaaa   ecx: c3c91020   edx: 00000000
esi: c113a000   edi: c3c32000   ebp: c01d4000   esp: c3c33e98
ds: 0018   es: 0018   ss: 0018
Process mem_test (pid: 64, stackpage=3Dc3c33000)
Stack: c3e7c180 c3c32000 0000000b c3c32000 c0115385 00000202 00015553
aaaaaab2 =

       c0109340 0000000b 00000000 c010fb35 c01a4abe c3c33f78 00000000
c3c32000 =

       00000000 c010f824 00000020 c11fc1cc c11fc1b0 c11fae90 40001ffc
00030001 =

Call Trace: [<c0115385>] [<c0109340>] [<c010fb35>] [<c010f824>]
[<ffff0006>] [<c010f95c>] [<ffff0006>] =

       [<c010f824>] [<c015f244>] [<c0119422>] [<c0108f64>] [<c0110018>]
[<c012dba1>] [<c012d122>] [<c0108e4b>] =


Code: 39 bb 84 00 00 00 75 27 c7 43 5c 11 00 00 00 ff 83 80 05 00 =


c012dad6 T chrdev_open
c012db1f T kdevname
c012db47 T cdevname
c012db81 t sock_no_open

Hope it helps,

Andrew
--------------8C66712E00934968BF8EC49F
Content-Type: text/plain; charset=us-ascii;
 name="mem_test.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mem_test.c"


#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

//#define SIZE 32*1024*1024

unsigned int patt[] = {
    0xaaaaaaaa,
    0x55555555,
    0xffffffff,
    0xa5a5a5a5,
    0x5a5a5a5a,
    0x11111111,
    0x22222222,
    0x44444444,
    0x88888888,
    0x00000000
};


int main(int argc, char **argv){

    int i, k;
    unsigned int *mem, SIZE;

    if(argc < 2){
        printf("Format is: %s SIZE\n", argv[0]);
        exit(1);
    }

    SIZE = strtol(argv[1], 0x0, 0x0);

    fprintf(stderr, "Doing Malloc\n");
    mem = (unsigned int *) malloc(SIZE);
    for(k = 0; patt[k] != 0x0; k++){
        fprintf(stderr, "Doing Write pattern: 0x%08x\n", patt[k]);
        for(i = SIZE>>2; i > 0; i--){
            mem[i] = patt[k];
        }
        fprintf(stderr, "Doing Read  pattern: 0x%08x\n", patt[k]);
        for(i = SIZE>>2; i > 0; i--){
            if(mem[i] != patt[k]){
                printf("Mem missmatch at: %d, with patt: 0x%08x\n", i, patt[k]);
            }
        }
        fprintf(stderr, "Done pattern: 0x%08x\n", patt[k]);
    }
    printf("\n");
    return 0;
}

--------------8C66712E00934968BF8EC49F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
