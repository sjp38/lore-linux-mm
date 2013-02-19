Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id D87BB6B0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 20:33:18 -0500 (EST)
Message-ID: <1361237574.3263.20.camel@thor.lan>
Subject: Re: kernel BUG at mm/slub.c:3409, 3.8.0-rc7
From: Peter Hurley <peter@hurleysoftware.com>
Date: Mon, 18 Feb 2013 20:32:54 -0500
In-Reply-To: <0000013cefd3a4bc-f5472b15-2ac5-4898-854a-07c65e81f771-000000@email.amazonses.com>
References: <9699daeed06dc8837f792bfdf486da45@visp.net.lb>
	 <0000013cefd3a4bc-f5472b15-2ac5-4898-854a-07c65e81f771-000000@email.amazonses.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Denys Fedoryshchenko <denys@visp.net.lb>
Cc: Marcin Slusarz <marcin.slusarz@gmail.com>, dri-devel@lists.freedesktop.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

[+cc Marcin Slusarz, dri-devel]

On Tue, 2013-02-19 at 00:21 +0000, Christoph Lameter wrote:
> The problem is that the subsystem attempted to call kfree with a pointer
> that was not obtained via a slab allocation.
> 
> On Sat, 16 Feb 2013, Denys Fedoryshchenko wrote:
> 
> > Hi
> >
> > Worked for a while on 3.8.0-rc7, generally it is fine, then suddenly laptop
> > stopped responding to keyboard and mouse.
> > Sure it can be memory corruption by some other module, but maybe not. Worth to
> > report i guess.
> > After reboot checked logs and found this:
> >
> > Feb 16 00:40:17 localhost kernel: [23260.079253] ------------[ cut here
> > ]------------
> > Feb 16 00:40:17 localhost kernel: [23260.079257] kernel BUG at mm/slub.c:3409!
> > Feb 16 00:40:17 localhost kernel: [23260.079259] invalid opcode: 0000 [#1] SMP
> > Feb 16 00:40:17 localhost kernel: [23260.079262] Modules linked in:
> > ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4
> > xt_state nf_conntrack ipt_REJECT xt_CHECKSUM iptable_mangle iptable_filter
> > ip_tables tun bridge stp llc nouveau snd_hda_codec_hdmi coretemp kvm_intel

Was there an allocation failure earlier in the log?

Might be this nouveau bug (linux-next at the time was 3.8 now):
https://bugs.freedesktop.org/show_bug.cgi?id=58087

I think this was fixed but neither bug report has a cross reference :(

The original report is here:
https://bugzilla.kernel.org/show_bug.cgi?id=51291

Pekka,
Can you please re-assign the bugzilla #51291 above to DRI? Thanks.

Regards,
Peter Hurley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
