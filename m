Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E1B068D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 05:05:52 -0500 (EST)
Date: Tue, 16 Nov 2010 19:03:09 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC PATCH] Make swap accounting default behavior configurable
 v3
Message-Id: <20101116190309.4c767874.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101116081544.GA19247@tiehlicka.suse.cz>
References: <20101110125154.GC5867@tiehlicka.suse.cz>
	<20101111094613.eab2ec0b.nishimura@mxp.nes.nec.co.jp>
	<20101111093155.GA20630@tiehlicka.suse.cz>
	<20101112094118.b02b669f.nishimura@mxp.nes.nec.co.jp>
	<20101112083103.GB7285@tiehlicka.suse.cz>
	<20101115101335.8880fd87.nishimura@mxp.nes.nec.co.jp>
	<20101115083540.GA20156@tiehlicka.suse.cz>
	<20101116134800.7d8b612d.nishimura@mxp.nes.nec.co.jp>
	<20101116081544.GA19247@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, balbir@linux.vnet.ibm.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Nov 2010 09:15:44 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Tue 16-11-10 13:48:00, Daisuke Nishimura wrote:
> > Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> Thank you. What should be next steps? Waiting for other ACKs or push it
> through Andrew?
I recommend you to resend the patch removing "RFC" in a clean patch format
(i.e. without any quotes).

> Btw. is this a stable tree material? I guess that distribution would
> like to have this patch and the stable is the easiest way how to deliver
> this.
> 
It's not stable material. This is not a BUG or anything that meets the conditions
described in Documentation/stable_kernel_rules.txt.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
