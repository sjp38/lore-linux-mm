Date: Wed, 17 Nov 1999 10:44:11 +0100 (CET)
From: Jesus Peco <peco@iit.upco.es>
Subject: 128M
Message-ID: <Pine.LNX.4.10.9911171033130.655-100000@robleda.iit.upco.es>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

   I have a Pentium II celeron and RedHat6.0 with
128M RAM. I have just recompiled the kernel 2.2.5-15
for a pentium II processor.

   I have changed the lilo.conf like this:

boot=/dev/hda
map=/boot/map
install=/boot/boot.b
prompt
timeout=50

image=/boot/vmlinuz131099
        label=linux
        root=/dev/hda3
        read-only
	append="mem=128m"
other=/dev/hda1
        label=winnt
        table=/dev/hda


I have also tried to put append="mem=127M" and
append="mem=128M", but unfortunately, after saving
this file and running 

/sbin/lilo -v

I run 

free

which reports that I only have 64M. I reboot and
the same thing happens when I run free or when I
see the Settings->Information->Memory window from
KDE.

Is there a way to make linux see I have 128M?
Do I have a hardware problem?
Is it a software configuration problem?

	Thank you very much!

---------------------------------------------------
Jesus Pascual Peco Gonzalez

E-mail: peco@iit.upco.es

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
