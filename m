Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3735E6B0083
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 03:01:45 -0400 (EDT)
Received: by gxk3 with SMTP id 3so1261409gxk.14
        for <linux-mm@kvack.org>; Fri, 10 Jul 2009 00:24:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090608091044.880249722@intel.com>
References: <20090608091044.880249722@intel.com>
Date: Fri, 10 Jul 2009 15:24:29 +0800
Message-ID: <ab418ea90907100024xe95ab44pb0809d262e616565@mail.gmail.com>
Subject: Re: [PATCH 0/3] make mapped executable pages the first class citizen
	(with test cases)
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi,

I was able to launch some tests with SPEC cpu2006.
The benchmark was based on mmotm
commit 0b7292956dbdfb212abf6e3c9cfb41e9471e1081 on a intel  Q6600 box with
4G ram. The kernel cmdline mem=3D500M was used to see how good exec-prot ca=
n
be under memory stress.

Following are the results:

                                  Estimated
                Base     Base       Base
Benchmarks      Ref.   Run Time     Ratio

mmotm with 500M
400.perlbench    9770        671      14.6  *
401.bzip2        9650       1011       9.55 *
403.gcc          8050        774      10.4  *
462.libquantum  20720       1213      17.1  *


mmot-prot with 500M
400.perlbench    9770        658      14.8  *
401.bzip2        9650       1007       9.58 *
403.gcc          8050        749      10.8  *
462.libquantum  20720       1116      18.6  *

mmotm with 4G ( allowing the full working sets)
400.perlbench    9770        594      16.5  *
401.bzip2        9650        828      11.7  *
403.gcc          8050        523      15.4  *
462.libquantum  20720       1121      18.5  *


It's worth noting that SPEC documented "The CPU2006 benchmarks
(code + workload) have been designed to fit within about 1GB of
physical memory",
and the exec vm sizes of these programs are as below:
perlbench  956KB
bzip2         56KB
gcc          3008KB
libquantum  36KB


Are we expecting to see more good results for cpu-bound programs (e.g.
scientific ones)
with large number of exec pages ?


Best Regards,

Nai Xia

On Mon, Jun 8, 2009 at 5:10 PM, Wu Fengguang<fengguang.wu@intel.com> wrote:
> Andrew,
>
> I managed to back this patchset with two test cases :)
>
> They demonstrated that
> - X desktop responsiveness can be *doubled* under high memory/swap pressu=
re
> - it can almost stop major faults when the active file list is slowly sca=
nned
> =A0because of undergoing partially cache hot streaming IO
>
> The details are included in the changelog.
>
> Thanks,
> Fengguang
> --
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
