Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 102796B0024
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 02:31:18 -0400 (EDT)
Message-ID: <4DE5DCA8.7070704@fnarfbargle.com>
Date: Wed, 01 Jun 2011 14:31:04 +0800
From: Brad Campbell <lists2009@fnarfbargle.com>
MIME-Version: 1.0
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
References: <4DE44333.9000903@fnarfbargle.com> <20110531054729.GA16852@liondog.tnic> <4DE4B432.1090203@fnarfbargle.com> <20110531103808.GA6915@eferding.osrc.amd.com> <4DE4FA2B.2050504@fnarfbargle.com> <alpine.LSU.2.00.1105311517480.21107@sister.anvils> <4DE589C5.8030600@fnarfbargle.com> <20110601011527.GN19505@random.random> <alpine.LSU.2.00.1105312120530.22808@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1105312120530.22808@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On 01/06/11 12:52, Hugh Dickins wrote:

>
> I guess Brad could try SLUB debugging, boot with slub_debug=P
> for poisoning perhaps; though it might upset alignments and
> drive the problem underground.  Or see if the same happens
> with SLAB instead of SLUB.

Not much use I'm afraid.
This is all I get in the log

[ 3161.300073] 
=============================================================================
[ 3161.300147] BUG kmalloc-512: Freechain corrupt

The qemu process is then frozen, unkillable but reported in state "R"

13881 ?        R      3:27 /usr/bin/qemu -S -M pc-0.13 -enable-kvm -m 
1024 -smp 2,sockets=2,cores=1,threads=1 -nam

The machine then progressively dies until it's frozen solid with no 
further error messages.

I stupidly forgot to do an alt-sysrq-t prior to doing an alt-sysrq-b, 
but at least it responded to that.

On the bright side I can reproduce it at will.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
