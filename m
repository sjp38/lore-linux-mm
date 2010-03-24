Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2976B01E5
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 09:28:20 -0400 (EDT)
Subject: Re: [rfc][patch] mm: lockdep page lock
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100316022153.GJ2869@laptop>
References: <20100315155859.GE2869@laptop>
	 <20100315180759.GA7744@quack.suse.cz>  <20100316022153.GJ2869@laptop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 24 Mar 2010 14:28:11 +0100
Message-ID: <1269437291.5109.238.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-03-16 at 13:21 +1100, Nick Piggin wrote:
>=20
>=20
> Agreed (btw. Peter is there any way to turn lock debugging back on?
> it's annoying when cpufreq hotplug code or something early breaks and
> you have to reboot in order to do any testing).

Not really, the only way to do that is to get the full system back into
a known (zero) lock state and then fully reset the lockdep state.

It might be possible using the freezer, but I haven't really looked at
that, its usually simpler to simply fix the offending code or simply not
build it in your kernel.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
