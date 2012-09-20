Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 529746B005A
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 14:43:07 -0400 (EDT)
Date: Thu, 20 Sep 2012 20:43:01 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: PROBLEM: machine hung after a struggle with oom
Message-ID: <20120920184301.GB17181@liondog.tnic>
References: <CAG3eYYRTm=ZgEJvjYLe4cN1VJr+Hia6pkSfSPgWO_UvXt1Dshg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAG3eYYRTm=ZgEJvjYLe4cN1VJr+Hia6pkSfSPgWO_UvXt1Dshg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?UMOpdGVyIEFuZHLDoXMgRmVsdsOpZ2k=?= <petschy@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

Adding linux-mm.

Btw, this is how you do bug reports! Good job.

On Thu, Sep 20, 2012 at 07:06:04PM +0200, PA(C)ter AndrA!s FelvA(C)gi wrote:
> Hello,
> 
> my machine hung today after some serious disk trashing caused by out
> of memory contition(s).
> 
> I didn't do anything unusual. There was an xtem window with a few
> tabs, iceweasel/firefox, chromium and codelite running. I already
> worked for some hours, started a build, then in the middle of it, the
> disk (sdb, where the 2G swap partition is) started working real
> intesively. This was unlikely, because the system and my home dir is
> on ssd / btrfs (sda) for a few months now, so normally things go
> quietly.
> 
> The system started struggling, the mouse moved really slow, pressing
> the num-lock and seeing the results on the led had quite some lag
> (3-14 secs). Tried to switch back to console via ctrl-alt-f1, after
> quite a few seconds it did switch, where I saw an oops regarding some
> btrfs extent function.
> 
> Switched back to X, took a few minutes to get back the title/border of
> the topmost window. Meanwhile, 3 small windows appeared slowly (the
> disk was still trashing like hell) notifying about an oops, and
> waiting for action. The mouse moved pixel-by-pixel, was useless. Then,
> after about 15 minutes, the disk stopped working, and silence set in.
> Num-lock and the kb in general wasn't responding, nor the mouse. Tried
> to unplug the kb and plug in an usb one, but no luck. Tried to ping
> the machine, it was unreachable. After a few minutes I pulled the
> plug. At reboot, I was informed about some orphaned inodes, but that
> was all, the system is up and running since then.
> 
> I don't know what triggered the swapping. From the logs it seems that
> the chromium processes were the first victims, but I wasn't using the
> browser, I was compiling my project. I haven't experienced any similar
> behaviour recently. I had plenty of free space on the btrfs partition
> (22G used out of 200G). I attached the relevant part from the kern.log
> (starting from the first oom and ending at the reboot), also I'm
> providing the info required for bug reports, hope that helps.
> 
> Kind regards, Peter
> 
> 
> $ sh scripts/ver_linux
> If some fields are empty or look unusual you may have an old version.
> Compare to the current minimal requirements in Documentation/Changes.
> 
> Linux lobster 3.5.3 #10 SMP Thu Sep 6 12:25:33 CEST 2012 x86_64 GNU/Linux
> 
> Gnu C                  4.7
> Gnu make               3.81
> binutils               2.22
> util-linux             scripts/ver_linux: 23: scripts/ver_linux:
> fdformat: not found
> mount                  support
> module-init-tools      found
> Linux C Library        2.13
> Dynamic linker (ldd)   2.13
> Procps                 3.3.3
> Kbd                    1.15.3
> Sh-utils               8.13
> Modules Loaded         snd_hda_codec_realtek snd_hda_intel
> snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm
> snd_page_alloc snd_seq_midi snd_seq_midi_event snd_rawmidi snd_seq
> crc32c_intel ghash_clmulni_intel snd_seq_device aesni_intel snd_timer
> aes_x86_64 snd k10temp fam15h_power aes_generic cryptd edac_mce_amd
> edac_core nouveau soundcore video i2c_piix4 mxm_wmi drm_kms_helper ttm
> evdev wmi usbhid r8169 mii
> 
> $ cat /proc/cpuinfo
> processor	: 0
> vendor_id	: AuthenticAMD
> cpu family	: 21
> model		: 1
> model name	: AMD FX(tm)-8120 Eight-Core Processor
> stepping	: 2
> microcode	: 0x6000626
> cpu MHz		: 3624.392
> cache size	: 2048 KB
> physical id	: 0
> siblings	: 8
> core id		: 0
> cpu cores	: 4
> apicid		: 0
> initial apicid	: 0
> fpu		: yes
> fpu_exception	: yes
> cpuid level	: 13
> wp		: yes
> flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
> pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt
> pdpe1gb rdtscp lm constant_tsc rep_good nopl nonstop_tsc extd_apicid
> aperfmperf pni pclmulqdq monitor ssse3 cx16 sse4_1 sse4_2 popcnt aes
> xsave avx lahf_lm cmp_legacy svm extapic cr8_legacy abm sse4a
> misalignsse 3dnowprefetch osvw ibs xop skinit wdt lwp fma4 nodeid_msr
> topoext perfctr_core arat cpb hw_pstate npt lbrv svm_lock nrip_save
> tsc_scale vmcb_clean flushbyasid decodeassists pausefilter pfthreshold
> bogomips	: 7248.78
> TLB size	: 1536 4K pages
> clflush size	: 64
> cache_alignment	: 64
> address sizes	: 48 bits physical, 48 bits virtual
> power management: ts ttp tm 100mhzsteps hwpstate cpb
> 
> [7 other cores omitted]
> 
> $ cat /proc/modules
> snd_hda_codec_realtek 67064 1 - Live 0xffffffffa016c000
> snd_hda_intel 30220 4 - Live 0xffffffffa0289000
> snd_hda_codec 90583 2 snd_hda_codec_realtek,snd_hda_intel, Live
> 0xffffffffa0264000
> snd_hwdep 13148 1 snd_hda_codec, Live 0xffffffffa0248000
> snd_pcm_oss 44847 0 - Live 0xffffffffa0258000
> snd_mixer_oss 22044 3 snd_pcm_oss, Live 0xffffffffa024d000
> snd_pcm 75438 3 snd_hda_intel,snd_hda_codec,snd_pcm_oss, Live 0xffffffffa022f000
> snd_page_alloc 17065 2 snd_hda_intel,snd_pcm, Live 0xffffffffa0212000
> snd_seq_midi 12848 0 - Live 0xffffffffa0226000
> snd_seq_midi_event 13316 1 snd_seq_midi, Live 0xffffffffa01fa000
> snd_rawmidi 26914 1 snd_seq_midi, Live 0xffffffffa021e000
> snd_seq 52897 2 snd_seq_midi,snd_seq_midi_event, Live 0xffffffffa0204000
> crc32c_intel 12747 0 - Live 0xffffffffa0219000
> ghash_clmulni_intel 12981 0 - Live 0xffffffffa01ff000
> snd_seq_device 13132 3 snd_seq_midi,snd_rawmidi,snd_seq, Live 0xffffffffa01e7000
> aesni_intel 50435 0 - Live 0xffffffffa01ec000
> snd_timer 26606 2 snd_pcm,snd_seq, Live 0xffffffffa01df000
> aes_x86_64 16796 1 aesni_intel, Live 0xffffffffa01d9000
> snd 60845 15 snd_hda_codec_realtek,snd_hda_intel,snd_hda_codec,snd_hwdep,snd_pcm_oss,snd_mixer_oss,snd_pcm,snd_rawmidi,snd_seq,snd_seq_device,snd_timer,
> Live 0xffffffffa01c9000
> k10temp 12618 0 - Live 0xffffffffa01c4000
> fam15h_power 12597 0 - Live 0xffffffffa01bf000
> aes_generic 33026 2 aesni_intel,aes_x86_64, Live 0xffffffffa01ac000
> cryptd 14560 2 ghash_clmulni_intel,aesni_intel, Live 0xffffffffa0067000
> edac_mce_amd 21093 0 - Live 0xffffffffa0165000
> edac_core 43036 0 - Live 0xffffffffa0159000
> nouveau 843331 2 - Live 0xffffffffa006c000
> soundcore 13026 3 snd, Live 0xffffffffa0154000
> video 17631 1 nouveau, Live 0xffffffffa0061000
> i2c_piix4 12536 0 - Live 0xffffffffa0017000
> mxm_wmi 12473 1 nouveau, Live 0xffffffffa004d000
> drm_kms_helper 35294 1 nouveau, Live 0xffffffffa0057000
> ttm 61344 1 nouveau, Live 0xffffffffa003d000
> evdev 17406 15 - Live 0xffffffffa0029000
> wmi 17339 2 nouveau,mxm_wmi, Live 0xffffffffa0033000
> usbhid 44463 0 - Live 0xffffffffa001d000
> r8169 58988 0 - Live 0xffffffffa0007000
> mii 12675 1 r8169, Live 0xffffffffa0000000
> 
> $ cat /proc/ioports
> 0000-0cf7 : PCI Bus 0000:00
>   0000-001f : dma1
>   0020-0021 : pic1
>   0040-0043 : timer0
>   0050-0053 : timer1
>   0060-0060 : keyboard
>   0064-0064 : keyboard
>   0070-0073 : rtc0
>   0080-008f : dma page reg
>   00a0-00a1 : pic2
>   00c0-00df : dma2
>   00f0-00ff : fpu
>   0220-0225 : pnp 00:01
>   0228-022f : pnp 00:02
>   0290-0294 : pnp 00:01
>   03c0-03df : vga+
>   03f8-03ff : serial
>   040b-040b : pnp 00:02
>   04d0-04d1 : pnp 00:01
>   04d6-04d6 : pnp 00:02
>   0800-08fe : pnp 00:02
>     0800-0803 : ACPI PM1a_EVT_BLK
>     0804-0805 : ACPI PM1a_CNT_BLK
>     0808-080b : ACPI PM_TMR
>     0810-0815 : ACPI CPU throttle
>     0820-0827 : ACPI GPE0_BLK
>     0850-0850 : ACPI PM2_CNT_BLK
>   0900-091f : pnp 00:02
>   0a10-0a17 : pnp 00:02
>   0b00-0b0f : pnp 00:02
>   0b10-0b1f : pnp 00:02
>   0b20-0b3f : pnp 00:02
>   0c00-0c01 : pnp 00:02
>   0c14-0c14 : pnp 00:02
>   0c50-0c52 : pnp 00:02
>   0c6c-0c6d : pnp 00:02
>   0c6f-0c6f : pnp 00:02
>   0cd0-0cd1 : pnp 00:02
>   0cd2-0cd3 : pnp 00:02
>   0cd4-0cdf : pnp 00:02
> 0cf8-0cff : PCI conf1
> 0d00-ffff : PCI Bus 0000:00
>   9000-9fff : PCI Bus 0000:06
>   a000-afff : PCI Bus 0000:05
>     af00-af7f : 0000:05:0e.0
>   b000-bfff : PCI Bus 0000:01
>   c000-cfff : PCI Bus 0000:04
>   d000-dfff : PCI Bus 0000:03
>     de00-deff : 0000:03:00.0
>       de00-deff : r8169
>   e000-efff : PCI Bus 0000:02
>   fb00-fb0f : 0000:00:11.0
>     fb00-fb0f : ahci
>   fc00-fc03 : 0000:00:11.0
>     fc00-fc03 : ahci
>   fd00-fd07 : 0000:00:11.0
>     fd00-fd07 : ahci
>   fe00-fe03 : 0000:00:11.0
>     fe00-fe03 : ahci
>   ff00-ff07 : 0000:00:11.0
>     ff00-ff07 : ahci
> 
> $ cat /proc/iomem
> 00000000-0000ffff : reserved
> 00010000-00091fff : System RAM
> 00092000-0009f7ff : RAM buffer
> 0009f800-0009ffff : reserved
> 000a0000-000bffff : PCI Bus 0000:00
> 000c0000-000dffff : PCI Bus 0000:00
>   000c0000-000c7fff : Video ROM
> 000f0000-000fffff : reserved
>   000f0000-000fffff : System ROM
> 00100000-cfd9ffff : System RAM
>   01000000-01613166 : Kernel code
>   01613167-01872b7f : Kernel data
>   01902000-0198efff : Kernel bss
>   c4000000-c7ffffff : GART
> cfda0000-cfdd0fff : ACPI Non-volatile Storage
> cfdd1000-cfdfffff : ACPI Tables
> cfe00000-cfefffff : reserved
>   cfe00000-cfefffff : pnp 00:0b
> cff00000-cfffffff : RAM buffer
> d0000000-febfffff : PCI Bus 0000:00
>   d0000000-dfffffff : PCI Bus 0000:01
>     d0000000-dfffffff : 0000:01:00.0
>   e0000000-efffffff : PCI MMCONFIG 0000 [bus 00-ff]
>     e0000000-efffffff : reserved
>       e0000000-efffffff : pnp 00:0a
>   fa000000-fcffffff : PCI Bus 0000:01
>     fa000000-faffffff : 0000:01:00.0
>     fb000000-fbffffff : 0000:01:00.0
>     fc000000-fc01ffff : 0000:01:00.0
>   fd500000-fd5fffff : PCI Bus 0000:03
>   fd600000-fd6fffff : PCI Bus 0000:02
>   fd700000-fd7fffff : PCI Bus 0000:06
>   fd800000-fd8fffff : PCI Bus 0000:06
>   fd900000-fd9fffff : PCI Bus 0000:02
>     fd9f8000-fd9fffff : 0000:02:00.0
>       fd9f8000-fd9fffff : xhci_hcd
>   fda00000-fdafffff : PCI Bus 0000:05
>   fdb00000-fdbfffff : PCI Bus 0000:05
>     fdbff000-fdbff7ff : 0000:05:0e.0
>   fdc00000-fdcfffff : PCI Bus 0000:04
>   fdd00000-fddfffff : PCI Bus 0000:04
>     fddf8000-fddfffff : 0000:04:00.0
>       fddf8000-fddfffff : xhci_hcd
>   fde00000-fdefffff : PCI Bus 0000:03
>     fdef8000-fdefbfff : 0000:03:00.0
>       fdef8000-fdefbfff : r8169
>     fdeff000-fdefffff : 0000:03:00.0
>       fdeff000-fdefffff : r8169
>   fdff4000-fdff7fff : 0000:00:14.2
>     fdff4000-fdff7fff : ICH HD audio
>   fdff8000-fdff80ff : 0000:00:16.2
>     fdff8000-fdff80ff : ehci_hcd
>   fdff9000-fdff9fff : 0000:00:16.0
>     fdff9000-fdff9fff : ohci_hcd
>   fdffa000-fdffafff : 0000:00:14.5
>     fdffa000-fdffafff : ohci_hcd
>   fdffb000-fdffb0ff : 0000:00:13.2
>     fdffb000-fdffb0ff : ehci_hcd
>   fdffc000-fdffcfff : 0000:00:13.0
>     fdffc000-fdffcfff : ohci_hcd
>   fdffd000-fdffd0ff : 0000:00:12.2
>     fdffd000-fdffd0ff : ehci_hcd
>   fdffe000-fdffefff : 0000:00:12.0
>     fdffe000-fdffefff : ohci_hcd
>   fdfff000-fdfff3ff : 0000:00:11.0
>     fdfff000-fdfff3ff : ahci
> fec00000-ffffffff : reserved
>   fec00000-fec003ff : IOAPIC 0
>   fec30000-fec33fff : amd_iommu
>   fed00000-fed003ff : HPET 0
>   fed40000-fed44fff : PCI Bus 0000:00
>   fee00000-fee00fff : Local APIC
>     fee00400-fee00fff : pnp 00:02
>   fff80000-fffeffff : pnp 00:0b
>   ffff0000-ffffffff : pnp 00:0b
> 100000000-22effffff : System RAM
> 22f000000-22fffffff : RAM buffer
> 
> # lspci -vvv
> 00:00.0 Host bridge: Advanced Micro Devices [AMD] nee ATI RD890 PCI to
> PCI bridge (external gfx0 port B) (rev 02)
> 	Subsystem: Advanced Micro Devices [AMD] nee ATI RD890 PCI to PCI
> bridge (external gfx0 port B)
> 	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort+ >SERR- <PERR- INTx-
> 	Region 3: Memory at <ignored> (64-bit, non-prefetchable)
> 	Capabilities: [f0] HyperTransport: MSI Mapping Enable+ Fixed+
> 	Capabilities: [c4] HyperTransport: Slave or Primary Interface
> 		Command: BaseUnitID=0 UnitCnt=20 MastHost- DefDir- DUL-
> 		Link Control 0: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=0
> IsocEn- LSEn- ExtCTL- 64b-
> 		Link Config 0: MLWI=16bit DwFcIn- MLWO=16bit DwFcOut- LWI=8bit
> DwFcInEn- LWO=8bit DwFcOutEn-
> 		Link Control 1: CFlE- CST- CFE- <LkFail+ Init- EOC+ TXO+ <CRCErr=0
> IsocEn- LSEn- ExtCTL- 64b-
> 		Link Config 1: MLWI=8bit DwFcIn- MLWO=8bit DwFcOut- LWI=8bit
> DwFcInEn- LWO=8bit DwFcOutEn-
> 		Revision ID: 3.00
> 		Link Frequency 0: [d]
> 		Link Error 0: <Prot- <Ovfl- <EOC- CTLTm-
> 		Link Frequency Capability 0: 200MHz+ 300MHz- 400MHz+ 500MHz- 600MHz+
> 800MHz+ 1.0GHz+ 1.2GHz+ 1.4GHz- 1.6GHz- Vend-
> 		Feature Capability: IsocFC+ LDTSTOP+ CRCTM- ECTLT- 64bA+ UIDRD-
> 		Link Frequency 1: 200MHz
> 		Link Error 1: <Prot- <Ovfl- <EOC- CTLTm-
> 		Link Frequency Capability 1: 200MHz- 300MHz- 400MHz- 500MHz- 600MHz-
> 800MHz- 1.0GHz- 1.2GHz- 1.4GHz- 1.6GHz- Vend-
> 		Error Handling: PFlE- OFlE- PFE- OFE- EOCFE- RFE- CRCFE- SERRFE- CF-
> RE- PNFE- ONFE- EOCNFE- RNFE- CRCNFE- SERRNFE-
> 		Prefetchable memory behind bridge Upper: 00-00
> 		Bus Number: 00
> 	Capabilities: [40] HyperTransport: Retry Mode
> 	Capabilities: [54] HyperTransport: UnitID Clumping
> 	Capabilities: [9c] HyperTransport: #1a
> 	Capabilities: [70] MSI: Enable- Count=1/4 Maskable- 64bit-
> 		Address: 00000000  Data: 0000
> 
> 00:00.2 IOMMU: Advanced Micro Devices [AMD] nee ATI RD990 I/O Memory
> Management Unit (IOMMU)
> 	Subsystem: Advanced Micro Devices [AMD] nee ATI RD990 I/O Memory
> Management Unit (IOMMU)
> 	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx+
> 	Interrupt: pin A routed to IRQ 40
> 	Capabilities: [40] Secure device <?>
> 	Capabilities: [54] MSI: Enable+ Count=1/1 Maskable- 64bit+
> 		Address: 00000000feeff00c  Data: 4151
> 	Capabilities: [64] HyperTransport: MSI Mapping Enable+ Fixed+
> 
> 00:02.0 PCI bridge: Advanced Micro Devices [AMD] nee ATI RD890 PCI to
> PCI bridge (PCI express gpp port B) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort+ <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
> 	I/O behind bridge: 0000b000-0000bfff
> 	Memory behind bridge: fa000000-fcffffff
> 	Prefetchable memory behind bridge: 00000000d0000000-00000000dfffffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort+
> <TAbort- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA- VGA+ MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [50] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag+ RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> 			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> 		LnkCap:	Port #0, Speed 5GT/s, Width x16, ASPM L0s L1, Latency L0 <1us, L1 <8us
> 			ClockPM- Surprise- LLActRep+ BwNot+
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+ DLActive+
> BWMgmt- ABWMgmt-
> 		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
> 			Slot #2, PowerLimit 75.000W; Interlock- NoCompl+
> 		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
> 			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
> 		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
> 			Changed: MRL- PresDet+ LinkState+
> 		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+ ARIFwd+
> 		DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis- ARIFwd-
> 		LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-,
> Selectable De-emphasis: -3.5dB
> 			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance-
> ComplianceSOS-
> 			 Compliance De-emphasis: -6dB
> 		LnkSta2: Current De-emphasis Level: -3.5dB, EqualizationComplete-,
> EqualizationPhase1-
> 			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> 	Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit-
> 		Address: 00000000  Data: 0000
> 	Capabilities: [b0] Subsystem: Advanced Micro Devices [AMD] nee ATI Device 5a14
> 	Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
> 	Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
> 	Capabilities: [190 v1] Access Control Services
> 		ACSCap:	SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+ UpstreamFwd+
> EgressCtrl- DirectTrans+
> 		ACSCtl:	SrcValid+ TransBlk- ReqRedir+ CmpltRedir+ UpstreamFwd+
> EgressCtrl- DirectTrans-
> 	Kernel driver in use: pcieport
> 
> 00:04.0 PCI bridge: Advanced Micro Devices [AMD] nee ATI RD890 PCI to
> PCI bridge (PCI express gpp port D) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
> 	I/O behind bridge: 0000e000-0000efff
> 	Memory behind bridge: fd900000-fd9fffff
> 	Prefetchable memory behind bridge: 00000000fd600000-00000000fd6fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [50] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag+ RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> 			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> 		LnkCap:	Port #0, Speed 5GT/s, Width x2, ASPM L0s L1, Latency L0 <1us, L1 <8us
> 			ClockPM- Surprise- LLActRep+ BwNot+
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+
> BWMgmt+ ABWMgmt+
> 		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
> 			Slot #4, PowerLimit 75.000W; Interlock- NoCompl+
> 		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
> 			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
> 		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
> 			Changed: MRL- PresDet+ LinkState+
> 		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+ ARIFwd+
> 		DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis- ARIFwd-
> 		LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-,
> Selectable De-emphasis: -3.5dB
> 			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance-
> ComplianceSOS-
> 			 Compliance De-emphasis: -6dB
> 		LnkSta2: Current De-emphasis Level: -3.5dB, EqualizationComplete-,
> EqualizationPhase1-
> 			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> 	Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit-
> 		Address: 00000000  Data: 0000
> 	Capabilities: [b0] Subsystem: Advanced Micro Devices [AMD] nee ATI Device 5a14
> 	Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
> 	Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
> 	Capabilities: [190 v1] Access Control Services
> 		ACSCap:	SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+ UpstreamFwd+
> EgressCtrl- DirectTrans+
> 		ACSCtl:	SrcValid+ TransBlk- ReqRedir+ CmpltRedir+ UpstreamFwd+
> EgressCtrl- DirectTrans-
> 	Kernel driver in use: pcieport
> 
> 00:09.0 PCI bridge: Advanced Micro Devices [AMD] nee ATI RD890 PCI to
> PCI bridge (PCI express gpp port H) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
> 	I/O behind bridge: 0000d000-0000dfff
> 	Memory behind bridge: fd500000-fd5fffff
> 	Prefetchable memory behind bridge: 00000000fde00000-00000000fdefffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [50] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag+ RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> 			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> 		LnkCap:	Port #4, Speed 5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <8us
> 			ClockPM- Surprise- LLActRep+ BwNot+
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+
> BWMgmt+ ABWMgmt-
> 		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
> 			Slot #9, PowerLimit 75.000W; Interlock- NoCompl+
> 		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
> 			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
> 		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
> 			Changed: MRL- PresDet+ LinkState+
> 		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+ ARIFwd+
> 		DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis- ARIFwd-
> 		LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-,
> Selectable De-emphasis: -3.5dB
> 			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance-
> ComplianceSOS-
> 			 Compliance De-emphasis: -6dB
> 		LnkSta2: Current De-emphasis Level: -3.5dB, EqualizationComplete-,
> EqualizationPhase1-
> 			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> 	Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit-
> 		Address: 00000000  Data: 0000
> 	Capabilities: [b0] Subsystem: Advanced Micro Devices [AMD] nee ATI Device 5a14
> 	Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
> 	Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
> 	Capabilities: [190 v1] Access Control Services
> 		ACSCap:	SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+ UpstreamFwd+
> EgressCtrl- DirectTrans+
> 		ACSCtl:	SrcValid+ TransBlk- ReqRedir+ CmpltRedir+ UpstreamFwd+
> EgressCtrl- DirectTrans-
> 	Kernel driver in use: pcieport
> 
> 00:0a.0 PCI bridge: Advanced Micro Devices [AMD] nee ATI RD890 PCI to
> PCI bridge (external gfx1 port A) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
> 	I/O behind bridge: 0000c000-0000cfff
> 	Memory behind bridge: fdd00000-fddfffff
> 	Prefetchable memory behind bridge: 00000000fdc00000-00000000fdcfffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [50] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag+ RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> 			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> 		LnkCap:	Port #5, Speed 5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <8us
> 			ClockPM- Surprise- LLActRep+ BwNot+
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+
> BWMgmt+ ABWMgmt+
> 		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
> 			Slot #10, PowerLimit 75.000W; Interlock- NoCompl+
> 		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
> 			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
> 		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
> 			Changed: MRL- PresDet+ LinkState+
> 		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+ ARIFwd+
> 		DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis- ARIFwd-
> 		LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-,
> Selectable De-emphasis: -3.5dB
> 			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance-
> ComplianceSOS-
> 			 Compliance De-emphasis: -6dB
> 		LnkSta2: Current De-emphasis Level: -3.5dB, EqualizationComplete-,
> EqualizationPhase1-
> 			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> 	Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit-
> 		Address: 00000000  Data: 0000
> 	Capabilities: [b0] Subsystem: Advanced Micro Devices [AMD] nee ATI Device 5a14
> 	Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
> 	Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
> 	Capabilities: [190 v1] Access Control Services
> 		ACSCap:	SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+ UpstreamFwd+
> EgressCtrl- DirectTrans+
> 		ACSCtl:	SrcValid+ TransBlk- ReqRedir+ CmpltRedir+ UpstreamFwd+
> EgressCtrl- DirectTrans-
> 	Kernel driver in use: pcieport
> 
> 00:11.0 SATA controller: Advanced Micro Devices [AMD] nee ATI
> SB7x0/SB8x0/SB9x0 SATA Controller [AHCI mode] (rev 40) (prog-if 01
> [AHCI 1.0])
> 	Subsystem: Giga-byte Technology Device b002
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 32, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 19
> 	Region 0: I/O ports at ff00 [size=8]
> 	Region 1: I/O ports at fe00 [size=4]
> 	Region 2: I/O ports at fd00 [size=8]
> 	Region 3: I/O ports at fc00 [size=4]
> 	Region 4: I/O ports at fb00 [size=16]
> 	Region 5: Memory at fdfff000 (32-bit, non-prefetchable) [size=1K]
> 	Capabilities: [70] SATA HBA v1.0 InCfgSpace
> 	Capabilities: [a4] PCI Advanced Features
> 		AFCap: TP+ FLR+
> 		AFCtrl: FLR-
> 		AFStatus: TP-
> 	Kernel driver in use: ahci
> 
> 00:12.0 USB controller: Advanced Micro Devices [AMD] nee ATI
> SB7x0/SB8x0/SB9x0 USB OHCI0 Controller (prog-if 10 [OHCI])
> 	Subsystem: Giga-byte Technology Device 5004
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 32, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 18
> 	Region 0: Memory at fdffe000 (32-bit, non-prefetchable) [size=4K]
> 	Kernel driver in use: ohci_hcd
> 
> 00:12.2 USB controller: Advanced Micro Devices [AMD] nee ATI
> SB7x0/SB8x0/SB9x0 USB EHCI Controller (prog-if 20 [EHCI])
> 	Subsystem: Giga-byte Technology Device 5004
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 32, Cache Line Size: 64 bytes
> 	Interrupt: pin B routed to IRQ 17
> 	Region 0: Memory at fdffd000 (32-bit, non-prefetchable) [size=256]
> 	Capabilities: [c0] Power Management version 2
> 		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 		Bridge: PM- B3+
> 	Capabilities: [e4] Debug port: BAR=1 offset=00e0
> 	Kernel driver in use: ehci_hcd
> 
> 00:13.0 USB controller: Advanced Micro Devices [AMD] nee ATI
> SB7x0/SB8x0/SB9x0 USB OHCI0 Controller (prog-if 10 [OHCI])
> 	Subsystem: Giga-byte Technology Device 5004
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 32, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 18
> 	Region 0: Memory at fdffc000 (32-bit, non-prefetchable) [size=4K]
> 	Kernel driver in use: ohci_hcd
> 
> 00:13.2 USB controller: Advanced Micro Devices [AMD] nee ATI
> SB7x0/SB8x0/SB9x0 USB EHCI Controller (prog-if 20 [EHCI])
> 	Subsystem: Giga-byte Technology Device 5004
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 32, Cache Line Size: 64 bytes
> 	Interrupt: pin B routed to IRQ 17
> 	Region 0: Memory at fdffb000 (32-bit, non-prefetchable) [size=256]
> 	Capabilities: [c0] Power Management version 2
> 		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 		Bridge: PM- B3+
> 	Capabilities: [e4] Debug port: BAR=1 offset=00e0
> 	Kernel driver in use: ehci_hcd
> 
> 00:14.0 SMBus: Advanced Micro Devices [AMD] nee ATI SBx00 SMBus
> Controller (rev 42)
> 	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
> 	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 
> 00:14.2 Audio device: Advanced Micro Devices [AMD] nee ATI SBx00
> Azalia (Intel HDA) (rev 40)
> 	Subsystem: Giga-byte Technology Device a002
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=slow >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 32, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 16
> 	Region 0: Memory at fdff4000 (64-bit, non-prefetchable) [size=16K]
> 	Capabilities: [50] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Kernel driver in use: snd_hda_intel
> 
> 00:14.3 ISA bridge: Advanced Micro Devices [AMD] nee ATI
> SB7x0/SB8x0/SB9x0 LPC host controller (rev 40)
> 	Subsystem: Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0 LPC
> host controller
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0
> 
> 00:14.4 PCI bridge: Advanced Micro Devices [AMD] nee ATI SBx00 PCI to
> PCI Bridge (rev 40) (prog-if 01 [Subtractive decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop+ ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 64
> 	Bus: primary=00, secondary=05, subordinate=05, sec-latency=64
> 	I/O behind bridge: 0000a000-0000afff
> 	Memory behind bridge: fdb00000-fdbfffff
> 	Prefetchable memory behind bridge: fda00000-fdafffff
> 	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort+ <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 
> 00:14.5 USB controller: Advanced Micro Devices [AMD] nee ATI
> SB7x0/SB8x0/SB9x0 USB OHCI2 Controller (prog-if 10 [OHCI])
> 	Subsystem: Giga-byte Technology Device 5004
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 32, Cache Line Size: 64 bytes
> 	Interrupt: pin C routed to IRQ 18
> 	Region 0: Memory at fdffa000 (32-bit, non-prefetchable) [size=4K]
> 	Kernel driver in use: ohci_hcd
> 
> 00:15.0 PCI bridge: Advanced Micro Devices [AMD] nee ATI
> SB700/SB800/SB900 PCI to PCI bridge (PCIE port 0) (prog-if 00 [Normal
> decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=06, subordinate=06, sec-latency=0
> 	I/O behind bridge: 00009000-00009fff
> 	Memory behind bridge: fd800000-fd8fffff
> 	Prefetchable memory behind bridge: 00000000fd700000-00000000fd7fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 	Capabilities: [50] Power Management version 3
> 		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag+ RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> 			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
> 			MaxPayload 128 bytes, MaxReadReq 128 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> 		LnkCap:	Port #247, Speed 2.5GT/s, Width x4, ASPM L0s L1, Latency L0
> <64ns, L1 <1us
> 			ClockPM- Surprise- LLActRep+ BwNot+
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed unknown, Width x16, TrErr- Train- SlotClk+ DLActive-
> BWMgmt- ABWMgmt-
> 		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise-
> 			Slot #0, PowerLimit 0.000W; Interlock- NoCompl+
> 		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
> 			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
> 		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
> 			Changed: MRL- PresDet- LinkState-
> 		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
> 		RootCap: CRSVisible-
> 		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> 		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+ ARIFwd-
> 		DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis- ARIFwd-
> 		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-,
> Selectable De-emphasis: -6dB
> 			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance-
> ComplianceSOS-
> 			 Compliance De-emphasis: -6dB
> 		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
> EqualizationPhase1-
> 			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> 	Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit+
> 		Address: 0000000000000000  Data: 0000
> 	Capabilities: [b0] Subsystem: Advanced Micro Devices [AMD] nee ATI Device 0000
> 	Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
> 	Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
> 	Kernel driver in use: pcieport
> 
> 00:16.0 USB controller: Advanced Micro Devices [AMD] nee ATI
> SB7x0/SB8x0/SB9x0 USB OHCI0 Controller (prog-if 10 [OHCI])
> 	Subsystem: Giga-byte Technology Device 5004
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 32, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 18
> 	Region 0: Memory at fdff9000 (32-bit, non-prefetchable) [size=4K]
> 	Kernel driver in use: ohci_hcd
> 
> 00:16.2 USB controller: Advanced Micro Devices [AMD] nee ATI
> SB7x0/SB8x0/SB9x0 USB EHCI Controller (prog-if 20 [EHCI])
> 	Subsystem: Giga-byte Technology Device 5004
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 32, Cache Line Size: 64 bytes
> 	Interrupt: pin B routed to IRQ 17
> 	Region 0: Memory at fdff8000 (32-bit, non-prefetchable) [size=256]
> 	Capabilities: [c0] Power Management version 2
> 		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 		Bridge: PM- B3+
> 	Capabilities: [e4] Debug port: BAR=1 offset=00e0
> 	Kernel driver in use: ehci_hcd
> 
> 00:18.0 Host bridge: Advanced Micro Devices [AMD] Family 15h Processor
> Function 0
> 	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Capabilities: [80] HyperTransport: Host or Secondary Interface
> 		Command: WarmRst+ DblEnd- DevNum=0 ChainSide- HostHide+ Slave- <EOCErr- DUL-
> 		Link Control: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=0
> IsocEn- LSEn+ ExtCTL- 64b+
> 		Link Config: MLWI=16bit DwFcIn- MLWO=16bit DwFcOut- LWI=8bit
> DwFcInEn- LWO=8bit DwFcOutEn-
> 		Revision ID: 3.00
> 		Link Frequency: [d]
> 		Link Error: <Prot- <Ovfl- <EOC- CTLTm-
> 		Link Frequency Capability: 200MHz+ 300MHz- 400MHz+ 500MHz- 600MHz+
> 800MHz+ 1.0GHz+ 1.2GHz+ 1.4GHz- 1.6GHz- Vend-
> 		Feature Capability: IsocFC+ LDTSTOP+ CRCTM- ECTLT- 64bA+ UIDRD- ExtRS- UCnfE-
> 
> 00:18.1 Host bridge: Advanced Micro Devices [AMD] Family 15h Processor
> Function 1
> 	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 
> 00:18.2 Host bridge: Advanced Micro Devices [AMD] Family 15h Processor
> Function 2
> 	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 
> 00:18.3 Host bridge: Advanced Micro Devices [AMD] Family 15h Processor
> Function 3
> 	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Capabilities: [f0] Secure device <?>
> 	Kernel driver in use: k10temp
> 
> 00:18.4 Host bridge: Advanced Micro Devices [AMD] Family 15h Processor
> Function 4
> 	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Kernel driver in use: fam15h_power
> 
> 00:18.5 Host bridge: Advanced Micro Devices [AMD] Family 15h Processor
> Function 5
> 	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 
> 01:00.0 VGA compatible controller: NVIDIA Corporation NV44 [GeForce
> 6200 TurboCache(TM)] (rev a1) (prog-if 00 [VGA controller])
> 	Subsystem: ASUSTeK Computer Inc. Device 81ae
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort+ <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 18
> 	Region 0: Memory at fa000000 (32-bit, non-prefetchable) [size=16M]
> 	Region 1: Memory at d0000000 (64-bit, prefetchable) [size=256M]
> 	Region 3: Memory at fb000000 (64-bit, non-prefetchable) [size=16M]
> 	[virtual] Expansion ROM at fc000000 [disabled] [size=128K]
> 	Capabilities: [60] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [68] MSI: Enable- Count=1/1 Maskable- 64bit+
> 		Address: 0000000000000000  Data: 0000
> 	Capabilities: [78] Express (v1) Endpoint, MSI 00
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 <4us
> 			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> 			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
> 			MaxPayload 128 bytes, MaxReadReq 512 bytes
> 		DevSta:	CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr- TransPend-
> 		LnkCap:	Port #0, Speed 2.5GT/s, Width x16, ASPM L0s L1, Latency L0
> <1us, L1 <4us
> 			ClockPM- Surprise- LLActRep- BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 128 bytes Disabled- Retrain- CommClk-
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk- DLActive-
> BWMgmt- ABWMgmt-
> 	Capabilities: [100 v1] Virtual Channel
> 		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
> 		Arb:	Fixed- WRR32- WRR64- WRR128-
> 		Ctrl:	ArbSelect=Fixed
> 		Status:	InProgress-
> 		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
> 			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
> 			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
> 			Status:	NegoPending- InProgress-
> 	Capabilities: [128 v1] Power Budgeting <?>
> 	Kernel driver in use: nouveau
> 
> 02:00.0 USB controller: Etron Technology, Inc. EJ168 USB 3.0 Host
> Controller (rev 01) (prog-if 30 [XHCI])
> 	Subsystem: Giga-byte Technology Device 5007
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 41
> 	Region 0: Memory at fd9f8000 (64-bit, non-prefetchable) [size=32K]
> 	Capabilities: [50] Power Management version 3
> 		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [70] MSI: Enable+ Count=1/4 Maskable+ 64bit+
> 		Address: 00000000feeff00c  Data: 4161
> 		Masking: 0000000e  Pending: 00000000
> 	Capabilities: [a0] Express (v2) Endpoint, MSI 00
> 		DevCap:	MaxPayload 1024 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
> 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> 			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+ FLReset-
> 			MaxPayload 128 bytes, MaxReadReq 512 bytes
> 		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
> 		LnkCap:	Port #0, Speed 5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <64us
> 			ClockPM+ Surprise- LLActRep- BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
> BWMgmt- ABWMgmt-
> 		DevCap2: Completion Timeout: Not Supported, TimeoutDis-
> 		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
> 		LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-,
> Selectable De-emphasis: -6dB
> 			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance-
> ComplianceSOS-
> 			 Compliance De-emphasis: -6dB
> 		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
> EqualizationPhase1-
> 			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> 	Capabilities: [100 v1] Advanced Error Reporting
> 		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
> MalfTLP- ECRC- UnsupReq- ACSViol-
> 		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
> MalfTLP- ECRC- UnsupReq- ACSViol-
> 		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
> MalfTLP+ ECRC- UnsupReq- ACSViol-
> 		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
> 		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
> 		AERCap:	First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-
> 	Capabilities: [190 v1] Device Serial Number 01-01-01-01-01-01-01-01
> 	Kernel driver in use: xhci_hcd
> 
> 03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 06)
> 	Subsystem: Giga-byte Technology GA-EP45-DS5/GA-EG45M-DS2H Motherboard
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 43
> 	Region 0: I/O ports at de00 [size=256]
> 	Region 2: Memory at fdeff000 (64-bit, prefetchable) [size=4K]
> 	Region 4: Memory at fdef8000 (64-bit, prefetchable) [size=16K]
> 	Capabilities: [40] Power Management version 3
> 		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
> 		Address: 00000000feeff00c  Data: 4171
> 	Capabilities: [70] Express (v2) Endpoint, MSI 01
> 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
> 			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> 			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 4096 bytes
> 		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
> 		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
> unlimited, L1 <64us
> 			ClockPM+ Surprise- LLActRep- BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
> BWMgmt- ABWMgmt-
> 		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
> 		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
> 		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-,
> Selectable De-emphasis: -6dB
> 			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance-
> ComplianceSOS-
> 			 Compliance De-emphasis: -6dB
> 		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
> EqualizationPhase1-
> 			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> 	Capabilities: [b0] MSI-X: Enable- Count=4 Masked-
> 		Vector table: BAR=4 offset=00000000
> 		PBA: BAR=4 offset=00000800
> 	Capabilities: [d0] Vital Product Data
> 		Unknown small resource type 00, will not decode more.
> 	Capabilities: [100 v1] Advanced Error Reporting
> 		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
> MalfTLP- ECRC- UnsupReq- ACSViol-
> 		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
> MalfTLP- ECRC- UnsupReq- ACSViol-
> 		UESvrt:	DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
> MalfTLP+ ECRC- UnsupReq- ACSViol-
> 		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
> 		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
> 		AERCap:	First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
> 	Capabilities: [140 v1] Virtual Channel
> 		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
> 		Arb:	Fixed- WRR32- WRR64- WRR128-
> 		Ctrl:	ArbSelect=Fixed
> 		Status:	InProgress-
> 		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
> 			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
> 			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
> 			Status:	NegoPending- InProgress-
> 	Capabilities: [160 v1] Device Serial Number 12-34-56-78-12-34-56-78
> 	Kernel driver in use: r8169
> 
> 04:00.0 USB controller: Etron Technology, Inc. EJ168 USB 3.0 Host
> Controller (rev 01) (prog-if 30 [XHCI])
> 	Subsystem: Giga-byte Technology Device 5007
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 42
> 	Region 0: Memory at fddf8000 (64-bit, non-prefetchable) [size=32K]
> 	Capabilities: [50] Power Management version 3
> 		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [70] MSI: Enable+ Count=1/4 Maskable+ 64bit+
> 		Address: 00000000feeff00c  Data: 4169
> 		Masking: 0000000e  Pending: 00000000
> 	Capabilities: [a0] Express (v2) Endpoint, MSI 00
> 		DevCap:	MaxPayload 1024 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> 			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
> 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> 			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+ FLReset-
> 			MaxPayload 128 bytes, MaxReadReq 512 bytes
> 		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
> 		LnkCap:	Port #0, Speed 5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <64us
> 			ClockPM+ Surprise- LLActRep- BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
> BWMgmt- ABWMgmt-
> 		DevCap2: Completion Timeout: Not Supported, TimeoutDis-
> 		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
> 		LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-,
> Selectable De-emphasis: -6dB
> 			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance-
> ComplianceSOS-
> 			 Compliance De-emphasis: -6dB
> 		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
> EqualizationPhase1-
> 			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> 	Capabilities: [100 v1] Advanced Error Reporting
> 		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
> MalfTLP- ECRC- UnsupReq- ACSViol-
> 		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
> MalfTLP- ECRC- UnsupReq- ACSViol-
> 		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
> MalfTLP+ ECRC- UnsupReq- ACSViol-
> 		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
> 		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
> 		AERCap:	First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-
> 	Capabilities: [190 v1] Device Serial Number 01-01-01-01-01-01-01-01
> 	Kernel driver in use: xhci_hcd
> 
> 05:0e.0 FireWire (IEEE 1394): VIA Technologies, Inc. VT6306/7/8 [Fire
> II(M)] IEEE 1394 OHCI Controller (rev c0) (prog-if 10 [OHCI])
> 	Subsystem: Giga-byte Technology GA-7VT600-1394 Motherboard
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 32 (8000ns max), Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 3
> 	Region 0: Memory at fdbff000 (32-bit, non-prefetchable) [size=2K]
> 	Region 1: I/O ports at af00 [size=128]
> 	Capabilities: [50] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2+ AuxCurrent=0mA PME(D0-,D1-,D2+,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-



-- 
Regards/Gruss,
    Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
