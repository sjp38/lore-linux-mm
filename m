Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 8E4D66B0068
	for <linux-mm@kvack.org>; Sat, 17 Nov 2012 03:40:08 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id lz20so4349318obb.14
        for <linux-mm@kvack.org>; Sat, 17 Nov 2012 00:40:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAGjg+kFUp_bACC-nze9og7+2XCXoURRunoTi4OY9-NgepU39mA@mail.gmail.com>
References: <1353083121-4560-1-git-send-email-mingo@kernel.org>
	<CAGjg+kFUp_bACC-nze9og7+2XCXoURRunoTi4OY9-NgepU39mA@mail.gmail.com>
Date: Sat, 17 Nov 2012 16:40:07 +0800
Message-ID: <CAGjg+kFD4r-J2Eq5tgTdCmktDLwDLaoteqw1Zc5vCnX6Rxb+DA@mail.gmail.com>
Subject: Re: [PATCH 00/19] latest numa/base patches
From: Alex Shi <lkml.alex@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Hugh Dickins <hughd@google.com>, Alex Shi <alex.shi@intel.com>

On Sat, Nov 17, 2012 at 4:35 PM, Alex Shi <lkml.alex@gmail.com> wrote:
> Just find imbalance issue on the patchset.
>
> I write a one line program:
> int main ()
> {
>         int i;
>         for (i=0; i< 1; )
>                 __asm__ __volatile__ ("nop");
> }
> it was compiled with name pl and start it on my 2 socket * 4 cores *
> HT NUMA machine:
> the cpu domain top like this:
> domain 0: span 4,12 level SIBLING
>   groups: 4 (cpu_power = 589) 12 (cpu_power = 589)
>   domain 1: span 0,2,4,6,8,10,12,14 level MC
>    groups: 4,12 (cpu_power = 1178) 6,14 (cpu_power = 1178) 0,8
> (cpu_power = 1178) 2,10 (cpu_power = 1178)
>    domain 2: span 0,2,4,6,8,10,12,14 level CPU
>     groups: 0,2,4,6,8,10,12,14 (cpu_power = 4712)
>     domain 3: span 0-15 level NUMA
>      groups: 0,2,4,6,8,10,12,14 (cpu_power = 4712) 1,3,5,7,9,11,13,15
> (cpu_power = 4712)
>
> $for ((i=0; i< I; i++)); do ./pl & done
> when I = 2, they are running on cpu 0,12
> I = 4, they are running on cpu 0,9,12,14
> I = 8, they are running on cpu 0,4,9,10,11,12,13,14
>

Ops, it was tested on latest V15 tip/master tree, head is
a7b7a8ad4476bb641c8455a4e0d7d0fd3eb86f90
not on this series.
Sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
