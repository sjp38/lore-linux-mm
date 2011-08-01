Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BB4A490014E
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 08:06:21 -0400 (EDT)
Received: by vwm42 with SMTP id 42so2807719vwm.14
        for <linux-mm@kvack.org>; Mon, 01 Aug 2011 05:06:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1107311426001.944@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1107290145080.3279@tiger>
	<alpine.DEB.2.00.1107291002570.16178@router.home>
	<alpine.DEB.2.00.1107311136150.12538@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1107311253560.12538@chino.kir.corp.google.com>
	<1312145146.24862.97.camel@jaguar>
	<alpine.DEB.2.00.1107311426001.944@chino.kir.corp.google.com>
Date: Mon, 1 Aug 2011 15:06:19 +0300
Message-ID: <CAOJsxLHB9jPNyU2qztbEHG4AZWjauCLkwUVYr--8PuBBg1=MCA@mail.gmail.com>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Aug 1, 2011 at 12:55 AM, David Rientjes <rientjes@google.com> wrote:
> I'm very confident that slub could beat slab on any system if you throw
> enough memory at it because its fastpaths are extremely efficient, but
> there's no business case for that.

Btw, I haven't measured this recently but in my testing, SLAB has
pretty much always used more memory than SLUB. So 'throwing more
memory at the problem' is definitely a reasonable approach for SLUB.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
