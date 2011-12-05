Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 54D876B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 15:10:38 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so2122212vbb.14
        for <linux-mm@kvack.org>; Mon, 05 Dec 2011 12:10:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111205192701.GA1531@x4.trippels.de>
References: <20111124085040.GA1677@x4.trippels.de>
	<20111202230412.GB12057@homer.localdomain>
	<20111203092845.GA1520@x4.trippels.de>
	<CAPM=9tyjZc9waC_ZBygW9zh+Zq-Wb1X5Y6yfsCCMPYwpFVWOOg@mail.gmail.com>
	<20111203122900.GA1617@x4.trippels.de>
	<CAH3drwZDOpPuQ_G=LwTiNsR5BNyJTNr+VJU74E6nS5AbKyQH0A@mail.gmail.com>
	<20111204010200.GA1530@x4.trippels.de>
	<20111205171046.GA4342@homer.localdomain>
	<20111205181549.GA1612@x4.trippels.de>
	<20111205191116.GB4342@homer.localdomain>
	<20111205192701.GA1531@x4.trippels.de>
Date: Mon, 5 Dec 2011 22:10:34 +0200
Message-ID: <CAOJsxLGCrNZnxZ70vpRGZ35GMK4MPDc4r6S=KTngQuL0eED94w@mail.gmail.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: Jerome Glisse <j.glisse@gmail.com>, Dave Airlie <airlied@gmail.com>, Christoph Lameter <cl@linux.com>, "Alex, Shi" <alex.shi@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, dri-devel@lists.freedesktop.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, tj@kernel.org, Alex Deucher <alexander.deucher@amd.com>

On Mon, Dec 5, 2011 at 9:27 PM, Markus Trippelsdorf
<markus@trippelsdorf.de> wrote:
>> > Yes the patch finally fixes the issue for me (tested with 120 kexec
>> > iterations).
>> > Thanks Jerome!
>>
>> Can you do a kick run on the modified patch ?
>
> This one is also OK after ~60 iterations.

Jerome, could you please include a reference to this LKML thread for
context and attribution for Markus for reporting and following up to
get the issue fixed in the changelog?

                              Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
