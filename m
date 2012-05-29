Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 3BC866B005C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 08:38:41 -0400 (EDT)
Message-ID: <1338295111.26856.57.camel@twins>
Subject: Re: [PATCH 2/2] block: Convert BDI proportion calculations to
 flexible proportions
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 29 May 2012 14:38:31 +0200
In-Reply-To: <20120529123408.GA23991@quack.suse.cz>
References: <1337878751-22942-1-git-send-email-jack@suse.cz>
	 <1337878751-22942-3-git-send-email-jack@suse.cz>
	 <1338220185.4284.19.camel@lappy> <20120529123408.GA23991@quack.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Sasha Levin <levinsasha928@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 2012-05-29 at 14:34 +0200, Jan Kara wrote:

> The only safe solution seems to be to create a variant of percpu counters
> that can be used from an interrupt. Or do you have other idea Peter?

> > [   20.680186]  [<ffffffff8325ac9b>] _raw_spin_lock+0x3b/0x70
> > [   20.680186]  [<ffffffff81993527>] ? __percpu_counter_sum+0x17/0xc0
> > [   20.680186]  [<ffffffff81993527>] __percpu_counter_sum+0x17/0xc0
> > [   20.680186]  [<ffffffff810ebf90>] ? init_timer_deferrable_key+0x20/0=
x20
> > [   20.680186]  [<ffffffff8195b5c2>] fprop_new_period+0x12/0x60
> > [   20.680186]  [<ffffffff811d929d>] writeout_period+0x3d/0xa0
> > [   20.680186]  [<ffffffff810ec0bf>] call_timer_fn+0x12f/0x260
> > [   20.680186]  [<ffffffff810ebf90>] ? init_timer_deferrable_key+0x20/0=
x20

Yeah, just make sure IRQs are disabled around doing that ;-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
