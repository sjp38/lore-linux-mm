Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2A3BD6B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 06:37:53 -0400 (EDT)
Date: Tue, 31 May 2011 12:38:08 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
Message-ID: <20110531103808.GA6915@eferding.osrc.amd.com>
References: <4DE44333.9000903@fnarfbargle.com>
 <20110531054729.GA16852@liondog.tnic>
 <4DE4B432.1090203@fnarfbargle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4DE4B432.1090203@fnarfbargle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brad Campbell <lists2009@fnarfbargle.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>

On Tue, May 31, 2011 at 05:26:10PM +0800, Brad Campbell wrote:
> On 31/05/11 13:47, Borislav Petkov wrote:
> >Looks like a KSM issue. Disabling CONFIG_KSM should at least stop your
> >machine from oopsing.
> >
> >Adding linux-mm.
> >
> 
> I initially thought that, so the second panic was produced with KSM
> disabled from boot.
> 
> echo 0 > /sys/kernel/mm/ksm/run
> 
> If you still think that compiling ksm out of the kernel will prevent
> it then I'm willing to give it a go.

Ok, from looking at the code, when KSM inits, it starts the ksm kernel
thread and it looks like your oops comes from the function that is run
in the kernel thread - ksm_scan_thread.

So even if you disable it from sysfs, it runs at least once.

Let's add some more people to Cc and see what happens :).

-- 
Regards/Gruss,
Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
