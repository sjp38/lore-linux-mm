Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 829426B0002
	for <linux-mm@kvack.org>; Fri,  1 Mar 2013 04:37:51 -0500 (EST)
Date: Fri, 1 Mar 2013 04:35:37 -0500
From: Chen Gong <gong.chen@linux.intel.com>
Subject: Re: [PATCH] x86: mm: Check if PUD is large when validating a kernel
 address v2
Message-ID: <20130301093537.GA12327@gchen.bj.intel.com>
References: <20130211145236.GX21389@suse.de>
 <20130213110202.GI4100@suse.de>
 <51304E29.40900@gmail.com>
 <20130301091513.GA11787@gchen.bj.intel.com>
 <5130731F.4000804@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pf9I7BMVVzbSWLtt"
Content-Disposition: inline
In-Reply-To: <5130731F.4000804@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 01, 2013 at 05:21:35PM +0800, Simon Jeons wrote:
> Date: Fri, 01 Mar 2013 17:21:35 +0800
> From: Simon Jeons <simon.jeons@gmail.com>
> To: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrew
>  Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
>  linux-mm@kvack.org, riel@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org
> Subject: Re: [PATCH] x86: mm: Check if PUD is large when validating a
>  kernel address v2
> User-Agent: Mozilla/5.0 (X11; Linux i686; rv:17.0) Gecko/20130221
>  Thunderbird/17.0.3
>=20
> On 03/01/2013 05:15 PM, Chen Gong wrote:
> >On Fri, Mar 01, 2013 at 02:43:53PM +0800, Simon Jeons wrote:
> >>Date: Fri, 01 Mar 2013 14:43:53 +0800
> >>From: Simon Jeons <simon.jeons@gmail.com>
> >>To: Mel Gorman <mgorman@suse.de>
> >>CC: Ingo Molnar <mingo@kernel.org>, Andrew Morton
> >>  <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
> >>  linux-mm@kvack.org, riel@redhat.com, mhocko@suse.cz, hannes@cmpxchg.o=
rg
> >>Subject: Re: [PATCH] x86: mm: Check if PUD is large when validating a
> >>  kernel address v2
> >>User-Agent: Mozilla/5.0 (X11; Linux i686; rv:17.0) Gecko/20130221
> >>  Thunderbird/17.0.3
> >>
> >>On 02/13/2013 07:02 PM, Mel Gorman wrote:
> >>>Andrew or Ingo, please pick up.
> >>>
> >>>Changelog since v1
> >>>   o Add reviewed-bys and acked-bys
> >>>
> >>>A user reported a bug whereby a backup process accessing /proc/kcore
> >>>caused an oops.
> >>>
> >>>  BUG: unable to handle kernel paging request at ffffbb00ff33b000
> >>>  IP: [<ffffffff8103157e>] kern_addr_valid+0xbe/0x110
> >>>  PGD 0
> >>>  Oops: 0000 [#1] SMP
> >>>  CPU 6
> >>>  Modules linked in: af_packet nfs lockd fscache auth_rpcgss nfs_acl s=
unrpc 8021q garp stp llc cpufreq_conservative cpufreq_userspace cpufreq_pow=
ersave acpi_cpufreq mperf microcode fuse nls_iso8859_1 nls_cp437 vfat fat l=
oop dm_mod ioatdma ipv6 ipv6_lib igb dca i7core_edac edac_core i2c_i801 i2c=
_core cdc_ether usbnet bnx2 mii iTCO_wdt iTCO_vendor_support shpchp rtc_cmo=
s pci_hotplug tpm_tis sg tpm pcspkr tpm_bios serio_raw button ext3 jbd mbca=
che uhci_hcd ehci_hcd usbcore sd_mod crc_t10dif usb_common processor therma=
l_sys hwmon scsi_dh_emc scsi_dh_rdac scsi_dh_alua scsi_dh_hp_sw scsi_dh ata=
_generic ata_piix libata megaraid_sas scsi_mod
> >>>
> >>>  Pid: 16196, comm: Hibackp Not tainted 3.0.13-0.27-default #1 IBM Sys=
tem x3550 M3 -[7944 K3G]-/94Y7614
> >>>  RIP: 0010:[<ffffffff8103157e>]  [<ffffffff8103157e>] kern_addr_valid=
+0xbe/0x110
> >>>  RSP: 0018:ffff88094165fe80  EFLAGS: 00010246
> >>>  RAX: 00003300ff33b000 RBX: ffff880100000000 RCX: 0000000000000000
> >>>  RDX: 0000000100000000 RSI: ffff880000000000 RDI: ff32b300ff33b400
> >>>  RBP: 0000000000001000 R08: 00003ffffffff000 R09: 0000000000000000
> >>>  R10: 22302e31223d6e6f R11: 0000000000000246 R12: 0000000000001000
> >>>  R13: 0000000000003000 R14: 0000000000571be0 R15: ffff88094165ff50
> >>>  FS:  00007ff152d33700(0000) GS:ffff88097f2c0000(0000) knlGS:00000000=
00000000
> >>>  CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> >>>  CR2: ffffbb00ff33b000 CR3: 00000009405a3000 CR4: 00000000000006e0
> >>>  DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> >>>  DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> >>>  Process Hibackp (pid: 16196, threadinfo ffff88094165e000, task ffff8=
808eb9ba600)
> >>>  Stack:
> >>>   ffffffff811b8aaa 0000000000004000 ffff880943fea480 ffff8808ef2bae50
> >>>   ffff880943d32980 fffffffffffffffb ffff8808ef2bae40 ffff88094165ff50
> >>>   0000000000004000 000000000056ebe0 ffffffff811ad847 000000000056ebe0
> >>>  Call Trace:
> >>>   [<ffffffff811b8aaa>] read_kcore+0x17a/0x370
> >>>   [<ffffffff811ad847>] proc_reg_read+0x77/0xc0
> >>>   [<ffffffff81151687>] vfs_read+0xc7/0x130
> >>>   [<ffffffff811517f3>] sys_read+0x53/0xa0
> >>>   [<ffffffff81449692>] system_call_fastpath+0x16/0x1b
> >>>
> >>>Investigation determined that the bug triggered when reading system RAM
> >>>at the 4G mark. On this system, that was the first address using 1G pa=
ges
> >>Do you mean there is one page which is 1G?
> >>
> >1GB support in native kernel is started from 2.6.27 with these 2 commits:
>=20
> Why call kernel native? Which kend of kernel is not native?
relative to VMM like Xen.

>=20
> >39c11e6 and b4718e6. For Intel CPU, from Westmere it supports 1GB page.
> >BTW, IBM System x3550 M3 is a Westmere based system.
> Is it only used in hugetlbfs page?

Yes by now.

--pf9I7BMVVzbSWLtt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRMHZpAAoJEI01n1+kOSLHMWcP/RUoDZHPpbe2oAwoN07Z/2CB
3hS/kCAOUriOt+76eouVQ2EsW5FGBHW7ojTihoO6znvAptPlMRkBIcGwjYH8HBN2
P0Bio74FhdQThnfYv0jexrMQI2LHuagJJ3z1ILzOdHADq40tIyMbomN6a6DmaYD9
ij1pVFKKKWUaGbl69oaX+MbPQd6xe/Y5GlhlQJId2JQxJCrxEP28QL5OkLC295OQ
3vGAoRiG8RJ9HsfJJ2o0SREYTkwfEJyTYo8BPZ6e3VSIlqcILig5BxLCAJoz5c29
pY/wc7kXCzrxBNUI1oxFqBN6Vst2PC0+tMjArLd/CNhcE/GNJ5SDTSvGy4ReGsHc
xEWjnG79N1VWQ9m3/Jjf7vuwwR1b/j9CTDrqtL/yxqOTbF2BGCK/KEieyoCatDgB
6GepsRXvZjtqmNrLPH4Tw3xUd+qsxVkJ4YhsxDNm/M77O4QplgE59fbAVlEOvZ8n
KPQsoEQ9hNJ93DitaZ4R7hTX7m7Bi7k3Jul1Q1JUMQ6n2mkO3bU0jgSmG318iKwy
LcifJj+jKIRGu2uO0pa1Ur0SR5FXjkYhxNRyZunWkCAkjB31R2/mwX+dRT4RmVDR
PRavQvL9BLY0TKp/OhGZISaRrL+MbG6C9JpDaxxX3a4SjzBrAU2HxfYB86LnP8y+
xPPUApjPDJ43OEEFt3oQ
=1VVA
-----END PGP SIGNATURE-----

--pf9I7BMVVzbSWLtt--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
