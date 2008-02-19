Received: by el-out-1112.google.com with SMTP id z25so1025877ele.8
        for <linux-mm@kvack.org>; Tue, 19 Feb 2008 05:07:09 -0800 (PST)
Message-ID: <fd87b6160802190507g74e64866pdbbda84826e0e5b8@mail.gmail.com>
Date: Tue, 19 Feb 2008 22:07:09 +0900
From: "John McCabe-Dansted" <gmatht@gmail.com>
Subject: Re: [linux-mm-cc] Announce: ccache release 0.1
In-Reply-To: <4cefeab80802190406w5dfcb257p1abff260c63522bc@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <4cefeab80802181339ia9609d3oeb238a9f549fc6e5@mail.gmail.com>
	 <fd87b6160802190233q7a6b95ecrff29ca70a9927e3b@mail.gmail.com>
	 <4cefeab80802190406w5dfcb257p1abff260c63522bc@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nitin Gupta <nitingupta910@gmail.com>
Cc: linux-mm-cc@laptop.org, linux-mm@kvack.org, linuxcompressed-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Feb 19, 2008 9:06 PM, Nitin Gupta <nitingupta910@gmail.com> wrote:
> On Feb 19, 2008 4:03 PM, John McCabe-Dansted <gmatht@gmail.com> wrote:
> > On Feb 19, 2008 6:39 AM, Nitin Gupta <nitingupta910@gmail.com> wrote:
> > > Some performance numbers for allocator and de/compressor can be found
> > > on project home. Currently it is tested on Linux kernel 2.6.23.x and
> > > 2.6.25-rc2 (x86 only). Please mail me/mailing-list any
> > > issues/suggestions you have.
> >
> > It caused Gutsy (2.6.22-14-generic) to crash when I did a swap off of
> > my hdd swap. I have a GB of ram, so I would have been fine without
> > ccache.
>
> These days "desktops with small memory" probably means virtual
> machines with, say, <512M RAM :-)

The Hardy liveCD is really snappy with a 192MB VM and and a 128MB
ccache swap. :)

> > I had swapped on a 400MB ccache swap.
> >
>
> I need /var/log/messages (or whatever file kernel logs to in Gutsy) to
> debug this.
> Please send it to me offline if its too big.

This seems to be the bit you want:

ubuntu-xp syslogd 1.4.1#21ubuntu3: restart.
Feb 19 08:07:31 ubuntu-xp -- MARK --
...
Feb 19 18:47:31 ubuntu-xp -- MARK --
Feb 19 18:59:51 ubuntu-xp kernel: [377208.185464] ccache: Unknown
symbol lzo1x_decompress_safe
Feb 19 18:59:51 ubuntu-xp kernel: [377208.185518] ccache: Unknown
symbol lzo1x_1_compress
Feb 19 18:59:51 ubuntu-xp kernel: [377208.185660] ccache: Unknown
symbol tlsf_free
Feb 19 18:59:51 ubuntu-xp kernel: [377208.185759] ccache: Unknown
symbol tlsf_malloc
Feb 19 18:59:51 ubuntu-xp kernel: [377208.185836] ccache: Unknown
symbol tlsf_destroy_memory_pool
Feb 19 18:59:51 ubuntu-xp kernel: [377208.185903] ccache: Unknown
symbol tlsf_create_memory_pool
Feb 19 19:00:10 ubuntu-xp kernel: [377227.049613] ccache: Unknown
symbol lzo1x_decompress_safe
Feb 19 19:00:10 ubuntu-xp kernel: [377227.049667] ccache: Unknown
symbol lzo1x_1_compress
Feb 19 19:00:10 ubuntu-xp kernel: [377227.049815] ccache: Unknown
symbol tlsf_free
Feb 19 19:00:10 ubuntu-xp kernel: [377227.049913] ccache: Unknown
symbol tlsf_malloc
Feb 19 19:00:10 ubuntu-xp kernel: [377227.049989] ccache: Unknown
symbol tlsf_destroy_memory_pool
Feb 19 19:00:10 ubuntu-xp kernel: [377227.050055] ccache: Unknown
symbol tlsf_create_memory_pool
Feb 19 19:01:07 ubuntu-xp kernel: [377283.369080] ccache: Compressed
swap size set to: 409600 KB
Feb 19 19:01:07 ubuntu-xp kernel: [377283.370015] TLSF: pool:
f8c11000, init_size=16384, max_size=0, grow_size=16384
Feb 19 19:02:21 ubuntu-xp kernel: [377358.145969] Adding 409596k swap
on /dev/ccache.  Priority:1 extents:1 across:409596k
Feb 19 19:02:57 ubuntu-xp kernel: [377393.198473] f8c0003c
Feb 19 19:02:57 ubuntu-xp kernel: [377393.198486] Modules linked in: ccache tlsf
 lzo1x_decompress lzo1x_compress atl2 af_packet binfmt_misc rfcomm l2cap bluetoo
th vboxdrv ppdev ipv6 i915 drm acpi_cpufreq cpufreq_conservative cpufreq_userspa
ce cpufreq_powersave cpufreq_ondemand cpufreq_stats freq_table video container s
bs button dock ac battery reiserfs nls_iso8859_1 nls_cp437 vfat fat w83627ehf i2
c_isa i2c_core lp snd_hda_intel snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy
snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq pcspkr serio_raw
 snd_timer snd_seq_device parport_pc parport psmouse xpad intel_agp usblp iTCO_w
dt iTCO_vendor_support agpgart snd soundcore snd_page_alloc shpchp pci_hotplug e
vdev usb_storage ide_core ext3 jbd mbcache usbhid hid sg sr_mod cdrom sd_mod ata
_generic libusual ata_piix floppy ohci1394 ieee1394 ehci_hcd libata scsi_mod uhc
i_hcd usbcore thermal processor fan fuse apparmor commoncap fbcon tileblit font
bitblit softcursor
Feb 19 19:05:25 ubuntu-xp syslogd 1.4.1#21ubuntu3: restart.
...

> > BTW, why is the default 10% of mem?
>
> I have no great justification for "10%".

Perhaps 100% (or maybe 50%) would be a more sensible default? For me
66% makes a huge difference to the Hardy liveCD performance. 10% makes
a difference but 50%+ goes from "ls /" taking 10s to snappy
performance even on large applications like Firefox.

> > This refers to the size of the
> > block device right? So even 100% would probably only use 50% of
> > physical memory for swap, assuming a 2:1 compression ratio.
>
> Yes, this is correct.
>
> Thanks,
> - Nitin

-- 
John C. McCabe-Dansted
PhD Student
University of Western Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
