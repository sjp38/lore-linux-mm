Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DE7996B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 20:18:20 -0400 (EDT)
Message-ID: <4DE5853E.8040106@fnarfbargle.com>
Date: Wed, 01 Jun 2011 08:18:06 +0800
From: Brad Campbell <lists2009@fnarfbargle.com>
MIME-Version: 1.0
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
References: <4DE44333.9000903@fnarfbargle.com> <20110531054729.GA16852@liondog.tnic> <4DE4B432.1090203@fnarfbargle.com> <20110531103808.GA6915@eferding.osrc.amd.com> <4DE4FA2B.2050504@fnarfbargle.com> <alpine.LSU.2.00.1105311517480.21107@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1105311517480.21107@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>

On 01/06/11 06:31, Hugh Dickins wrote:
>
> Brad, my suspicion is that in each case the top 16 bits of RDX have been
> mysteriously corrupted from ffff to 0000, causing the general protection
> faults.  I don't understand what that has to do with KSM.

No, nor do I. The panic I reproduced with KSM off was in a completely 
unrelated code path. To be honest I would not be surprised if it turns 
out I have dodgy RAM, although it has passed multiple memtests and I've 
tried clocking it down. Just a gut feeling.

> But it's only a suspicion, because I can't make sense of the "Code:"
> lines in your traces, they have more than the expected 64 bytes, and
> only one of them has a ">" (with no"<") to mark faulting instruction.

Yeah, with hindsight I must have removed them when I re-formatted the 
code from the oops. Each byte was one line in the syslog so there was a 
lot of deleting to get it to a postable format.

> I did try compiling the 2.6.39 kernel from your config, but of course
> we have different compilers, so although I got close, it wasn't exact.
>
> Would you mind mailing me privately (it's about 73MB) the "objdump -trd"
> output for your original vmlinux (with KSM on)?  (Those -trd options are
> the ones I'm used to typing, I bet not they're not all relevant.)
>
> Of course, it's only a tiny fraction of that output that I need,
> might be better to cut it down to remove_rmap_item_from_tree and
> dup_fd and ksm_scan_thread, if you have the time to do so.

Ok, so since my initial posting I've figured out how to get a clean oops 
out of netconsole, so tonight (after 9PM GMT+8) I'll reproduce the oops 
a couple of times. What about I upload the oops, plus the vmlinux, plus 
.config and System.map to a server with a fat pipe and give you a link 
to it?

At least I can reproduce it quickly and easily.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
