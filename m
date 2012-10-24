Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 6B4856B006E
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 20:34:41 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so5052408obc.14
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 17:34:40 -0700 (PDT)
Message-ID: <5087379B.6060400@gmail.com>
Date: Wed, 24 Oct 2012 08:34:35 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [Bug 49361] New: configuring TRANSPARENT_HUGEPAGE_ALWAYS can
 make system unresponsive and reboot
References: <bug-49361-27@https.bugzilla.kernel.org/> <20121023123613.1bcdf3ab.akpm@linux-foundation.org>
In-Reply-To: <20121023123613.1bcdf3ab.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, marc@offline.be

On 10/24/2012 03:36 AM, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Tue, 23 Oct 2012 00:06:18 +0000 (UTC)
> bugzilla-daemon@bugzilla.kernel.org wrote:

How to subscribe this bugzilla ML?

>
>> https://bugzilla.kernel.org/show_bug.cgi?id=49361
>>
>>             Summary: configuring TRANSPARENT_HUGEPAGE_ALWAYS can make
>>                      system unresponsive and reboot
>>             Product: Memory Management
>>             Version: 2.5
>>      Kernel Version: 3.6.2
>>            Platform: All
>>          OS/Version: Linux
>>                Tree: Mainline
>>              Status: NEW
>>            Severity: normal
>>            Priority: P1
>>           Component: Page Allocator
>>          AssignedTo: akpm@linux-foundation.org
>>          ReportedBy: marc@offline.be
>>          Regression: No
>>
>>
>> workaround: configure TRANSPARENT_HUGEPAGE_MADVISE instead
>>
>>
>>
>>   I run a bleeding edge gentoo with 2 6-core AMD CPUs. I daily updated
>> 3 gentoo systems on this computer all using -j13. Until recently, I
>> never experienced issues, CPUs may all go neer 100%, no problem.
>>
>>   Now, when building icedtea-7, for example, regardless of -j13 or -j1,
>> about 10 javac instances run threaded (either spreaded on multiple or
>> one core) and go to about 1000% CPU together.
>>
>>   Nothing else can be started. This can take 24 hours, no improvement.
>>
>>   Only one way to recover: kill -9 javac.
>>
>>   One time kernel rebooted, I could not find any relevant kernel logs
>> before reboot.
>>
>>
>>   I hd noticed khugepaged on top in top (just below 1000% CPU javac)
>> which made me look at HUGEPAGE settings.
>>
>>   FWIW, an strace on javac PID showed it doing nothing in futex
>>
>>   As said, MADVISE fixes issue.
>>
>>
>>   I am not sure if this is really a kernel bug, however, no matter how
>> bad programs behave, other programs should be able to get CPU and
>> reboot (unless perhaps watchdog) should not happen.
>>
>>   Even if not a kernel bug, it is strange that chanding one single
>> kernel config fixes issue and massive building works again.
>>
>>   I sincerely hope I provide hint to developers to fix/improve kernel
>> and I am willing to cooperate to get this happen. Note that for now I
>> have workaround in place (to build/cross-build my other systems on
>> this dedicated build host)
>>
>> standby ~ # /usr/src/linux-3.6.2-gentoo/scripts/ver_linux
>> If some fields are empty or look unusual you may have an old version.
>> Compare to the current minimal requirements in Documentation/Changes.
>>
>> Linux standby 3.6.2-gentoo #2 SMP Mon Oct 22 18:56:49 CEST 2012 x86_64 AMD
>> Opteron(tm) Processor 4184 AuthenticAMD GNU/Linux
>>
>> Gnu C                  4.7.2
>> Gnu make               3.82
>> binutils               2.22
>> util-linux             2.22.1
>> mount                  debug
>> module-init-tools      10
>> e2fsprogs              1.42.6
>> jfsutils               1.1.15
>> xfsprogs               3.1.8
>> quota-tools            4.00-pre1.
>> PPP                    2.4.5
>> Linux C Library        2.15
>> Dynamic linker (ldd)   2.15
>> Procps                 UNKNOWN
>> Net-tools              1.60_p20120127084908
>> Kbd                    1.15.3wip
>> Sh-utils               8.19
>> wireless-tools         30
>> Modules Loaded         fbcon bitblit softcursor font rfcomm w83627ehf hwmon_vid
>> fuse bnep autofs4 nfsd nfs_acl lockd sunrpc ipv6 af_packet quota_v2 quota_tree
>> video usbmouse usbkbd usbhid scsi_tgt output nvram nls_utf8 nls_ascii msr
>> mptspi scsi_transport_spi mptsas mptscsih mptbase libphy initio hid_apple drm
>> dm_log dm_mod cpuid configs configfs cifs btusb bluetooth rfkill async_memcpy
>> async_tx aic94xx libsas scsi_transport_sas nvidia usb_storage uas uvcvideo
>> videobuf2_vmalloc videobuf2_memops videobuf2_core videodev ub snd_usb_audio
>> snd_usbmidi_lib snd_hwdep snd_hda_codec_hdmi sp5100_tco nvidiafb vgastate
>> sr_mod i2c_algo_bit fb_ddc powernow_k8 i2c_piix4 mperf freq_table ohci_hcd
>> cdrom ehci_hcd ata_generic pata_acpi usbcore i2c_core usb_common k10temp e1000e
>> pata_atiixp kvm_amd kvm snd_ca0106 microcode pcspkr snd_ac97_codec serio_raw
>> ac97_bus firmware_class snd_rawmidi snd_seq_device snd_hda_intel snd_hda_codec
>> snd_pcm snd_page_alloc snd_timer 8250_pnp rtc_cmos processor thermal_sys hwmon
>> snd button soundcore unix
>>
>> -- 
>> Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
>> ------- You are receiving this mail because: -------
>> You are the assignee for the bug.
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
