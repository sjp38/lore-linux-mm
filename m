Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 075596B0099
	for <linux-mm@kvack.org>; Sun,  7 Nov 2010 18:55:09 -0500 (EST)
Received: by iwn9 with SMTP id 9so5406839iwn.14
        for <linux-mm@kvack.org>; Sun, 07 Nov 2010 15:55:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101107220353.115646194@cmpxchg.org>
References: <1288973333-7891-1-git-send-email-minchan.kim@gmail.com>
	<20101106010357.GD23393@cmpxchg.org>
	<AANLkTin9m65JVKRuStZ1-qhU5_1AY-GcbBRC0TodsfYC@mail.gmail.com>
	<20101107215030.007259800@cmpxchg.org>
	<20101107220353.115646194@cmpxchg.org>
Date: Mon, 8 Nov 2010 07:56:43 +0900
Message-ID: <AANLkTi=qO84k-KWaG2R_nQr7vxRA2E7DbO4=XhVrFzjv@mail.gmail.com>
Subject: Re: [patch 1/4] memcg: use native word to represent dirtyable pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 8, 2010 at 7:14 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> The memory cgroup dirty info calculation currently uses a signed
> 64-bit type to represent the amount of dirtyable memory in pages.
>
> This can instead be changed to an unsigned word, which will allow the
> formula to function correctly with up to 160G of LRU pages on a 32-bit
> system, assuming 4k pages. =A0That should be plenty even when taking
> racy folding of the per-cpu counters into account.
>
> This fixes a compilation error on 32-bit systems as this code tries to
> do 64-bit division.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reported-by: Dave Young <hidave.darkstar@gmail.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
