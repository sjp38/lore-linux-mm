Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CFC066B0033
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 08:40:11 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u27so11667887pfg.12
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 05:40:11 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0135.outbound.protection.outlook.com. [104.47.37.135])
        by mx.google.com with ESMTPS id p2si10895668pfd.273.2017.10.30.05.40.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 30 Oct 2017 05:40:09 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [pgtable_trans_huge_withdraw] BUG: unable to handle kernel NULL
 pointer dereference at 0000000000000020
Date: Mon, 30 Oct 2017 08:40:01 -0400
Message-ID: <3121F405-9F96-41B0-BD28-73BD8EA85B07@cs.rutgers.edu>
In-Reply-To: <20171030115819.33y7g47qnzrsmwwb@node.shutemov.name>
References: <CA+55aFxSJGeN=2X-uX-on1Uq2Nb8+v1aiMDz5H1+tKW_N5Q+6g@mail.gmail.com>
 <20171029225155.qcum5i75awrt5tzm@wfg-t540p.sh.intel.com>
 <20171029233701.4pjqaesnrjqshmzn@wfg-t540p.sh.intel.com>
 <20171030115819.33y7g47qnzrsmwwb@node.shutemov.name>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_448FB4E8-5C71-4C0F-8886-B4C0E1100BEA_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vineet Gupta <Vineet.Gupta1@synopsys.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Geliang Tang <geliangtang@163.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_448FB4E8-5C71-4C0F-8886-B4C0E1100BEA_=
Content-Type: text/plain; charset=utf-8; markup=markdown
Content-Transfer-Encoding: quoted-printable

On 30 Oct 2017, at 7:58, Kirill A. Shutemov wrote:

> On Mon, Oct 30, 2017 at 12:37:01AM +0100, Fengguang Wu wrote:
>> CC MM people.
>>
>> On Sun, Oct 29, 2017 at 11:51:55PM +0100, Fengguang Wu wrote:
>>> Hi Linus,
>>>
>>> Up to now we see the below boot error/warnings when testing v4.14-rc6=
=2E
>>>
>>> They hit the RC release mainly due to various imperfections in 0day's=

>>> auto bisection. So I manually list them here and CC the likely easy t=
o
>>> debug ones to the corresponding maintainers in the followup emails.
>>>
>>> boot_successes: 4700
>>> boot_failures: 247
>>>
>>> BUG:kernel_hang_in_test_stage: 152
>>> BUG:kernel_reboot-without-warning_in_test_stage: 10
>>> BUG:sleeping_function_called_from_invalid_context_at_kernel/locking/m=
utex.c: 1
>>> BUG:sleeping_function_called_from_invalid_context_at_kernel/locking/r=
wsem.c: 3
>>> BUG:sleeping_function_called_from_invalid_context_at_mm/page_alloc.c:=
 21
>>> BUG:soft_lockup-CPU##stuck_for#s: 1
>>> BUG:unable_to_handle_kernel: 13
>>
>> Here is the call trace:
>>
>> [  956.669197] [  956.670421] stress-ng: fail:  [27945] stress-ng-numa=
:
>> get_mempolicy: errno=3D22 (Invalid argument)
>> [  956.670422] [  956.671375] stress-ng: info:  [27945] 5 failures rea=
ched,
>> aborting stress process
>> [  956.671376] [  956.671551] BUG: unable to handle kernel NULL pointe=
r
>> dereference at 0000000000000020
>> [  956.671557] IP: pgtable_trans_huge_withdraw+0x4c/0xc0
>> [  956.671558] PGD 0 P4D 0 [  956.671560] Oops: 0000 [#1] SMP
>> [  956.671562] Modules linked in: salsa20_generic salsa20_x86_64 camel=
lia_generic camellia_aesni_avx2 camellia_aesni_avx_x86_64 camellia_x86_64=
 cast6_avx_x86_64 cast6_generic cast_common serpent_avx2 serpent_avx_x86_=
64 serpent_sse2_x86_64 serpent_generic twofish_generic twofish_avx_x86_64=
 ablk_helper twofish_x86_64_3way twofish_x86_64 twofish_common lrw tgr192=
 wp512 rmd320 rmd256 rmd160 rmd128 md4 sha512_ssse3 sha512_generic rpcsec=
_gss_krb5 auth_rpcgss nfsv4 dns_resolver intel_rapl sb_edac x86_pkg_temp_=
thermal intel_powerclamp sd_mod sg coretemp kvm_intel kvm mgag200 irqbypa=
ss ttm crct10dif_pclmul crc32_pclmul drm_kms_helper crc32c_intel syscopya=
rea ghash_clmulni_intel snd_pcm sysfillrect snd_timer pcbc sysimgblt fb_s=
ys_fops ahci snd aesni_intel crypto_simd mxm_wmi glue_helper libahci soun=
dcore cryptd
>> [  956.671592]  drm ipmi_si pcspkr libata shpchp ipmi_devintf ipmi_msg=
handler acpi_pad acpi_power_meter wmi ip_tables
>> [  956.671600] CPU: 78 PID: 28007 Comm: stress-ng-numa Not tainted 4.1=
4.0-rc6 #1
>> [  956.671600] Hardware name: Intel Corporation S2600WT2R/S2600WT2R, B=
IOS SE5C610.86B.01.01.0020.122820161512 12/28/2016
>> [  956.671601] task: ffff88101c97cd00 task.stack: ffffc90026b04000
>> [  956.671603] RIP: 0010:pgtable_trans_huge_withdraw+0x4c/0xc0
>> [  956.671604] RSP: 0018:ffffc90026b07c20 EFLAGS: 00010202
>> [  956.671604] RAX: ffffea00404c7b80 RBX: 0000000000000000 RCX: 000000=
0000000001
>> [  956.671605] RDX: 0000000000000001 RSI: ffff8810931ee000 RDI: ffff88=
1020f11000
>> [  956.671605] RBP: ffffc90026b07c28 R08: ffff88101a96a190 R09: 000055=
c2d5137000
>> [  956.671606] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88=
1020f11000
>> [  956.671606] R13: ffffc90026b07dd8 R14: ffff8810131ee538 R15: ffffea=
00404c7bb0
>> [  956.671607] FS:  0000000000000000(0000) GS:ffff882023080000(0000) k=
nlGS:0000000000000000
>> [  956.671608] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [  956.671609] CR2: 0000000000000020 CR3: 000000207ee09001 CR4: 000000=
00003606e0
>> [  956.671609] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000=
0000000000
>> [  956.671610] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 000000=
0000000400
>> [  956.671610] Call Trace:
>> [  956.671614]  zap_huge_pmd+0x28a/0x3a0
>> [  956.671617]  unmap_page_range+0x918/0x9c0
>> [  956.671619]  unmap_single_vma+0x7d/0xe0
>> [  956.671621]  unmap_vmas+0x51/0xa0
>> [  956.671622]  exit_mmap+0x96/0x190
>> [  956.671625]  mmput+0x6e/0x160
>> [  956.671626]  do_exit+0x2b3/0xb90
>> [  956.671627]  do_group_exit+0x43/0xb0
>> [  956.671628]  SyS_exit_group+0x14/0x20
>> [  956.671630]  entry_SYSCALL_64_fastpath+0x1a/0xa5
>> [  956.671631] RIP: 0033:0x7f92a15e11c8
>> [  956.671631] RSP: 002b:00007fff12384aa8 EFLAGS: 00000246 ORIG_RAX: 0=
0000000000000e7
>> [  956.671632] RAX: ffffffffffffffda RBX: 00007f92a1dea000 RCX: 00007f=
92a15e11c8
>> [  956.671633] RDX: 0000000000000000 RSI: 000000000000003c RDI: 000000=
0000000000
>> [  956.671633] RBP: 00007fff12384aa0 R08: 00000000000000e7 R09: ffffff=
ffffffff90
>> [  956.671634] R10: 00007f92a088b070 R11: 0000000000000246 R12: 00007f=
92a088add8
>> [  956.671634] R13: 00007fff12384a18 R14: 00007f92a1df4048 R15: 000000=
0000000000
>> [  956.671635] Code: 77 00 00 48 01 f0 48 ba 00 00 00 00 00 ea ff ff 4=
8 c1
>> e8 0c 48 c1 e0 06 48 01 d0 8b 50 30 85 d2 74 6d 55 48 89 e5 53 48 8b 5=
8 28
>> <48> 8b 53 20 48 8d 7b 20 48 39 d7 74 49 48 83 ea 20 48 85 d2 48 [
>> 956.671650] RIP: pgtable_trans_huge_withdraw+0x4c/0xc0 RSP: ffffc90026=
b07c20
>> [  956.671651] CR2: 0000000000000020
>> [  956.671695] ---[ end trace 9ac71716a2cdb192 ]---
>> [  956.672896] stress-ng: fail:  [27986] stress-ng-numa: get_mempolicy=
: errno=3D22 (Invalid argument)
>
> +Zi Yan.
>
> Could you check if the patch below helps?
>
> It seems we forgot to deposit page table on copying pmd migration entry=
=2E
> Current code just leaks newly allocated page table.
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 269b5df58543..84beba5dedda 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -941,6 +941,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct =
mm_struct *src_mm,
>  				pmd =3D pmd_swp_mksoft_dirty(pmd);
>  			set_pmd_at(src_mm, addr, src_pmd, pmd);
>  		}
> +		pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
>  		set_pmd_at(dst_mm, addr, dst_pmd, pmd);
>  		ret =3D 0;
>  		goto out_unlock;
> -- =

>  Kirill A. Shutemov

Thanks for fixing it.

It seems I also forgot to increase the corresponding counters. Does the p=
atch below look good to you?

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 269b5df58543..1981ed697dab 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -941,6 +941,9 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm=
_struct *src_mm,
                                pmd =3D pmd_swp_mksoft_dirty(pmd);
                        set_pmd_at(src_mm, addr, src_pmd, pmd);
                }
+               add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
+               atomic_long_inc(&dst_mm->nr_ptes);
+               pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
                set_pmd_at(dst_mm, addr, dst_pmd, pmd);
                ret =3D 0;
                goto out_unlock;



=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_448FB4E8-5C71-4C0F-8886-B4C0E1100BEA_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAln3HaEWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzNwhB/44IofM/MwQ8OILoqdq1SiMJAk6
hHDz97B+zICrpqr2HESpmSBmVoAuEOVGTkRn/Dz70m5iNA3Wz54UDfCbY/yvbyI1
GzmWYS+iatT0PJSicGb7xG+tpXB5kJSko1O2BPynW6ZuqbPVUhPmcr4ztR+vGj1z
MThg18boLY3PvLBzpYbeulWqmEl3YMh12dJ3b3h4asPGFOOUvjCvAudPlT4jJYG8
pZ2Vdaf5eaEbibqZ9BT0Lu6PEytO9B3z1ixnpQce63b5I4rD1YgvrbC6HYkseza9
GLQXbfb/beYX37owNJGeB+FO4rQFZy8yleB4Fu7aLg9L+9wFQxg9zmROQ7gE
=8+tf
-----END PGP SIGNATURE-----

--=_MailMate_448FB4E8-5C71-4C0F-8886-B4C0E1100BEA_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
