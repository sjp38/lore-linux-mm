Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1EC6B0098
	for <linux-mm@kvack.org>; Sun, 11 Jan 2015 08:40:49 -0500 (EST)
Received: by mail-we0-f174.google.com with SMTP id k48so15028188wev.5
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 05:40:48 -0800 (PST)
Received: from vps01.winsoft.pl (vps01.winsoft.pl. [5.133.9.51])
        by mx.google.com with ESMTPS id o4si8504704wia.79.2015.01.11.05.40.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Jan 2015 05:40:48 -0800 (PST)
Subject: Re: probably commit b3d574ae ( Linus github 10-01-2015) causes oops
 after run Android SDK Manager from Eclipse
references: <54B117C9.5080805@winsoft.pl> <54B256CC.6080804@suse.cz>
From: Krzysztof Kolasa <kkolasa@winsoft.pl>
message-id: <54B27D53.7050807@winsoft.pl>
Date: Sun, 11 Jan 2015 14:40:35 +0100
mime-version: 1.0
in-reply-to: <54B256CC.6080804@suse.cz>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-256; boundary="------------ms070100080001030800030404"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms070100080001030800030404
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: quoted-printable

OK CONFIG_DEBUG_BUGVERBOSE enabled

kernel BUG at mm/rmap.c:399!
this one line added with merged commit b3d574ae
after remove it:
----
diff --git a/mm/rmap.c b/mm/rmap.c
index 71cd5bd..68d115f 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -396,7 +396,6 @@ void unlink_anon_vmas(struct vm_area_struct *vma)
      list_for_each_entry_safe(avc, next, &vma->anon_vma_chain, same_vma)=
 {
          struct anon_vma *anon_vma =3D avc->anon_vma;

-        BUG_ON(anon_vma->degree);
          put_anon_vma(anon_vma);

          list_del(&avc->same_vma);
----
system working stable and not generate oops.

On 11.01.2015 11:56, Vlastimil Babka wrote:
> Re: subject
>
> why do you think it was this commit? bisection? The commit you point to=
 is
> "Merge branch 'akpm' (patches from Andrew)"
> It's possible that bisection pointed you to this, instead of the proper=
 commit
> though. Luckily, there are only 12 of them and ...
>
> On 01/10/2015 01:15 PM, Krzysztof Kolasa wrote:
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320920] ------------[ cut
>> here ]------------
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320927] Kernel BUG at
>> ffffffff81187f1f [verbose debug info unavailable]
> Could you enable CONFIG_DEBUG_BUGVERBOSE please? This should make the s=
tacktrace
> readable.
>
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320929] invalid opcode: 00=
00
>> [#3] SMP
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320932] Modules linked in:=

>> dm_crypt(E) pci_stub(E) vboxpci(OE) vboxnetadp(OE) vboxnetflt(OE)
>> vboxdrv(OE) c
>> use(E) arc4(E) md4(E) bnep(E) rfcomm(E) bluetooth(E) nls_utf8(E) cifs(=
E)
>> fscache(E) binfmt_misc(E) fglrx(OE) uvcvideo(E) videobuf2_vmalloc(E)
>> x86_pkg_
>> temp_thermal(E) videobuf2_memops(E) videobuf2_core(E) hp_wmi(E)
>> v4l2_common(E) wl(POE) kvm_intel(E) sparse_keymap(E) videodev(E) kvm(E=
)
>> ghash_clmulni_
>> intel(E) aesni_intel(E) aes_x86_64(E) lrw(E) gf128mul(E)
>> snd_hda_codec_idt(E) snd_hda_codec_hdmi(E) snd_hda_codec_generic(E)
>> glue_helper(E) ablk_helpe
>> r(E) snd_hda_intel(E) cryptd(E) snd_hda_controller(E) snd_hda_codec(E)=

>> snd_hwdep(E) snd_pcm(E) snd_seq_midi(E) snd_seq_midi_event(E)
>> microcode(E) snd_
>> rawmidi(E) snd_seq(E) snd_seq_device(E) snd_timer(E) snd(E) cfg80211(E=
)
>> soundcore(E) joydev(E) lpc_ich(E) hp_accel(E) wmi(E) serio_raw(E)
>> tpm_infineon
>> (E) lis3lv02d(E) amd_iommu_v2(E) input_polldev(E) video(E) tpm_tis(E)
>> mac_hid(E) parport_pc(E) ppdev(E) coretemp(E) lp(E) parport(E)
>> hid_generic(E) us
>> bhid(E) hid(E) mmc_block(E) psmouse(E) firewire_ohci(E) ahci(E)
>> libahci(E) sdhci_pci(E) e1000e(E) firewire_core(E) sdhci(E) crc_itu_t(=
E)
>> ptp(E) pps_co
>> re(E)
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320979] CPU: 1 PID: 6871
>> Comm: Sweeper thread Tainted: P      D    OE 3.19.0-rc3-winsoft-x64+ #=
10
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320981] Hardware name:
>> Hewlett-Packard HP ProBook 6560b/1619, BIOS 68SCE Ver. F.50 08/04/2014=

>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320983] task:
>> ffff88005d95b1c0 ti: ffff88018ee18000 task.ti: ffff88018ee18000
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320985] RIP:
>> 0010:[<ffffffff81187f1f>]  [<ffffffff81187f1f>] unlink_anon_vmas+0x1af=
/0x200
> Nevertheless, here we see unlink_anon_vmas, which would strongly point =
to
> 7a3ef208e662f4b63d ("mm: prevent endless growth of anon_vma hierarchy")=

> and we also have another report for that.
>
> Still your stracktrace could be useful to help determining the cause, i=
f you
> enabled the verbose debugging.
>
> Thanks.
>
>
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320993] RSP:
>> 0018:ffff88018ee1bba8  EFLAGS: 00010286
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320994] RAX:
>> ffff880182a47c50 RBX: ffff880182a47c40 RCX: ffff8801b9e1d638
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320996] RDX:
>> 00000000ffffffff RSI: ffff8801abb60630 RDI: ffff8801abb605f0
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.320998] RBP:
>> ffff88018ee1bbe8 R08: 00000000f70a2000 R09: 0000000000000000
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321000] R10:
>> ffff880182a47c60 R11: ffffea00060a91c0 R12: ffff8801b9e1d628
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321001] R13:
>> ffff8801b9e1d638 R14: ffff8801abb605f0 R15: ffff8801abb605f0
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321003] FS:
>> 0000000000000000(0000) GS:ffff88023f440000(0000) knlGS:000000000000000=
0
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321005] CS:  0010 DS: 002b=

>> ES: 002b CR0: 0000000080050033
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321007] CR2:
>> 00000000f653e70c CR3: 0000000001c12000 CR4: 00000000000407e0
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321008] Stack:
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321010] ffff8801b9e1d5c0
>> ffff8801abb605f0 ffff88018ee1bbe8 ffff88006a1d70b8
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321013] 00000000a3255000
>> 0000000000000000 ffff88018ee1bc58 ffff8801b9e1d5c0
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321016] ffff88018ee1bc38
>> ffffffff81179b58 ffff88018ee1bc38 0000000000000000
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321019] Call Trace:
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321025] [<ffffffff81179b58=
>]
>> free_pgtables+0xa8/0x120
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321029] [<ffffffff81183e5f=
>]
>> exit_mmap+0xdf/0x170
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321033] [<ffffffff81055984=
>]
>> mmput+0x64/0x130
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321036] [<ffffffff8105ab2f=
>]
>> do_exit+0x26f/0xb10
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321039] [<ffffffff8105b45f=
>]
>> do_group_exit+0x3f/0xa0
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321044] [<ffffffff81066d48=
>]
>> get_signal+0x1d8/0x5f0
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321047] [<ffffffff81002e10=
>]
>> do_signal+0x20/0x120
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321052] [<ffffffff810d0d01=
>]
>> ? compat_SyS_futex+0x71/0x140
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321055] [<ffffffff81002f80=
>]
>> do_notify_resume+0x70/0xa0
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321059] [<ffffffff8171ebc7=
>]
>> int_signal+0x12/0x17
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321061] Code: 44 24 10 48 =
8d
>> 50 f0 49 8d 44 24 10 49 39 c5 75 9b 48 83 c4 18 5b 41 5c 41 5d 41 5e 4=
1
>> 5f 5d
>>    c3 0f 1f 40 00 e8 c3 fa ff ff eb 99 <0f> 0b 80 3d ea 8e b6 00 00 74=
 16
>> 49 8d 7e 08 48 89 55 c8 e8 09
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321088] RIP
>> [<ffffffff81187f1f>] unlink_anon_vmas+0x1af/0x200
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321091]  RSP <ffff88018ee1=
bba8>
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321094] ---[ end trace
>> 1c9e464233c6be56 ]---
>> Jan 10 12:33:57 krzysiek-hp1 kernel: [ 3872.321096] Fixing recursive
>> fault but reboot is needed!
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>>
>


--=20
Przedsi=EAbiorstwo Handlowo-Us=B3ugowe "WINSOFT" Krzysztof Kolasa
ul. Libelta 15/3, 68-100 =AFaga=F1, NIP: 924-142-33-91, REGON: 970700380
Rachunek bankowy: PL 26 2490 0005 0000 4500 2204 2675 Alior Bank S.A.
tel. +48 602-31-78-77, +48 68-414-14-47, fax  +48 68-414-14-48



--------------ms070100080001030800030404
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
My5jcmwwWgYIKwYBBQUHAQEETjBMMCEGCCsGAQUFBzABhhVodHRwOi8vb2NzcC5jZXJ0dW0u
cGwwJwYIKwYBBQUHMAKGG2h0dHA6Ly93d3cuY2VydHVtLnBsL2wzLmNlcjAfBgNVHSMEGDAW
gBQEydqa3EpJd68wAwRmLsfO8vgXfTAdBgNVHQ4EFgQUg3ObCWDLHU3Y5vakFl1HoWw1S4Mw
DgYDVR0PAQH/BAQDAgTwMIIBPQYDVR0gBIIBNDCCATAwggEsBgoqhGgBhvZ3AgIDMIIBHDAl
BggrBgEFBQcCARYZaHR0cHM6Ly93d3cuY2VydHVtLnBsL0NQUzCB8gYIKwYBBQUHAgIwgeUw
IBYZVW5pemV0byBUZWNobm9sb2dpZXMgUy5BLjADAgEBGoHAVXNhZ2Ugb2YgdGhpcyBjZXJ0
aWZpY2F0ZSBpcyBzdHJpY3RseSBzdWJqZWN0ZWQgdG8gdGhlIENFUlRVTSBDZXJ0aWZpY2F0
aW9uIFByYWN0aWNlIFN0YXRlbWVudCAoQ1BTKSBpbmNvcnBvcmF0ZWQgYnkgcmVmZXJlbmNl
IGhlcmVpbiBhbmQgaW4gdGhlIHJlcG9zaXRvcnkgYXQgaHR0cHM6Ly93d3cuY2VydHVtLnBs
L3JlcG9zaXRvcnkuMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcDBDARBglghkgBhvhC
AQEEBAMCBaAwHQYDVR0RBBYwFIESa2tvbGFzYUB3aW5zb2Z0LnBsMA0GCSqGSIb3DQEBBQUA
A4IBAQACPfD98uTgRP0i58ATUDY5kfsHL2QFF+f8Umeih51R8yj02ZRskjZdU64QFpwkQ7YZ
vdinbsz7Umhn5UGYRHxuQ7rStRICABzAWA0VeIxGc7RR2VX5A8T14J0dF0RZm98arjTg3Ard
0iCg7yfSQOVB681ifQ7ClFm2mQFezXSuOeGmm5ZaR845moC++h6iEUbk9MMKZ/qchpFOvIAx
XzpWdLPR7c+WDHJgcE5ri22MQIDPmh2F4YanX+8N5vOGC/UL4mUYVvk7Lw3UcuoNxp1CV0Na
/IvxQkN57pEUWtLM9A29Usg4ghTte9b/FaSTuC/K+g8zCt+kQXPAOYPXDkl5MYID1TCCA9EC
AQEwgYwweDELMAkGA1UEBhMCUEwxIjAgBgNVBAoTGVVuaXpldG8gVGVjaG5vbG9naWVzIFMu
QS4xJzAlBgNVBAsTHkNlcnR1bSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTEcMBoGA1UEAxMT
Q2VydHVtIExldmVsIElJSSBDQQIQAcOHeikrqgxXLlmjYW/EmjANBglghkgBZQMEAgEFAKCC
AhkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUwMTExMTM0
MDM1WjAvBgkqhkiG9w0BCQQxIgQgIFmImrwa/+N8cioHheR6ZxDlCSBseB76doxeF+JdsGsw
bAYJKoZIhvcNAQkPMV8wXTALBglghkgBZQMEASowCwYJYIZIAWUDBAECMAoGCCqGSIb3DQMH
MA4GCCqGSIb3DQMCAgIAgDANBggqhkiG9w0DAgIBQDAHBgUrDgMCBzANBggqhkiG9w0DAgIB
KDCBnQYJKwYBBAGCNxAEMYGPMIGMMHgxCzAJBgNVBAYTAlBMMSIwIAYDVQQKExlVbml6ZXRv
IFRlY2hub2xvZ2llcyBTLkEuMScwJQYDVQQLEx5DZXJ0dW0gQ2VydGlmaWNhdGlvbiBBdXRo
b3JpdHkxHDAaBgNVBAMTE0NlcnR1bSBMZXZlbCBJSUkgQ0ECEAHDh3opK6oMVy5Zo2FvxJow
gZ8GCyqGSIb3DQEJEAILMYGPoIGMMHgxCzAJBgNVBAYTAlBMMSIwIAYDVQQKExlVbml6ZXRv
IFRlY2hub2xvZ2llcyBTLkEuMScwJQYDVQQLEx5DZXJ0dW0gQ2VydGlmaWNhdGlvbiBBdXRo
b3JpdHkxHDAaBgNVBAMTE0NlcnR1bSBMZXZlbCBJSUkgQ0ECEAHDh3opK6oMVy5Zo2FvxJow
DQYJKoZIhvcNAQEBBQAEggEAEQwXYvjypEYoQqI/UKYrgOgygwlzVs836Xcom2Pbf42EYd/h
sUCQCX3JoJs8qKn2yncWrFS5CO2n5yllyABIxWUDAqTuuSLP8lMUMVK/6LxKW5JCh6WEDNG3
E0aL+fDH27LN6lzPZCIJ7nSNGf0N5YnGo2lKxPY+0erNs4JxF/ttG6YugQyiv9OWXbfOLMnC
E/qWZWooRdT0Fn/6r+g3EH5qHqthObueOCvn6r7PXQ22Iy0Rt23U6S+/P8tdwqLWqFCUKkyF
Ak9vlFnTac+L2Yaf4G+OxY2Sv/3BNmbMtaBdWVXd1U5odv5l334BkKdIrCGTjI5RMNA4BsO3
iQ+1MQAAAAAAAA==
--------------ms070100080001030800030404--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
