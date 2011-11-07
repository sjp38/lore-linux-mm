Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A28466B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 18:42:57 -0500 (EST)
Date: Mon, 7 Nov 2011 23:43:37 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC PATCH] tmpfs: support user quotas
Message-ID: <20111107234337.1dc9d612@lxorguk.ukuu.org.uk>
In-Reply-To: <20111107230712.GA25769@tango.0pointer.de>
References: <1320614101.3226.5.camel@offbook>
	<20111107112952.GB25130@tango.0pointer.de>
	<1320675607.2330.0.camel@offworld>
	<20111107135823.3a7cdc53@lxorguk.ukuu.org.uk>
	<CAPXgP117Wkgvf1kDukjWt9yOye8xArpyX29xx36NT++s8TS5Rw@mail.gmail.com>
	<20111107225314.0e3976a6@lxorguk.ukuu.org.uk>
	<20111107230712.GA25769@tango.0pointer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lennart Poettering <mzxreary@0pointer.de>
Cc: Kay Sievers <kay.sievers@vrfy.org>, Davidlohr Bueso <dave@gnu.org>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, 8 Nov 2011 00:07:12 +0100
Lennart Poettering <mzxreary@0pointer.de> wrote:

> On Mon, 07.11.11 22:53, Alan Cox (alan@lxorguk.ukuu.org.uk) wrote:
> 
> > Per user would be quota, per process would be rlimit. Quite simple
> > really, nice standard interfaces we've had for years. Various systems
> 
> Uh, have you ever really looked at resource limits? Some of them are
> per-user, not per-process, i.e. RLIMIT_NPROC. And this would just be
> another one.

NPROC is a bit of an oddity.

And the standards have no idea how a resource limit hit for an fs would
be reported, nor how an app installer would check for it. Quota on the
other hand is defined behaviour.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
