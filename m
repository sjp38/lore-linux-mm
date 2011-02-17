Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 524F68D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 14:12:44 -0500 (EST)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p1HJCBRY010250
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 11:12:12 -0800
Received: by iyi20 with SMTP id 20so2727098iyi.14
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 11:12:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <m1pqqqfpzh.fsf@fess.ebiederm.org>
References: <20110216185234.GA11636@tiehlicka.suse.cz> <20110216193700.GA6377@elte.hu>
 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
 <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
 <20110217090910.GA3781@tiehlicka.suse.cz> <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
 <20110217163531.GF14168@elte.hu> <m1pqqqfpzh.fsf@fess.ebiederm.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 17 Feb 2011 11:11:51 -0800
Message-ID: <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in 2.6.38-rc4
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Ingo Molnar <mingo@elte.hu>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Feb 17, 2011 at 10:57 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> fedora 14
> ext4 on all filesystems

Your dmesg snippets had ext3 mentioned, though:

  <6>EXT3-fs (sda1): recovery required on readonly filesystem
  <6>EXT3-fs (sda1): write access will be enabled during recovery
  <6>EXT3-fs: barriers not enabled
  ..
  <6>EXT3-fs (sda1): recovery complete
  <6>EXT3-fs (sda1): mounted filesystem with ordered data mode
  <6>dracut: Mounted root filesystem /dev/sda1

not that I see that it should matter, but there's been some bigger
ext3 changes too (like the batched discard).

I don't really think ext3 is the issue, though.

> I was about to say this happens with DEBUG_PAGEALLOC enabled but it
> appears that options keeps eluding my fingers when I have a few minutes
> to play with it. =A0Perhaps this time will be the charm.

Please do. You seem to be much better at triggering it than anybody
else. And do the DEBUG_LIST and DEBUG_SLUB_ON things too (even if the
DEBUG_LIST thing won't catch list_move())

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
