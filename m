Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE746B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 02:49:38 -0500 (EST)
Received: by vcbfo13 with SMTP id fo13so1282307vcb.14
        for <linux-mm@kvack.org>; Sun, 06 Nov 2011 23:49:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <d19dddac-0713-47bf-bec7-04cc8d534b50@default>
References: <20111104164532.GO18879@redhat.com>
	<d19dddac-0713-47bf-bec7-04cc8d534b50@default>
Date: Mon, 7 Nov 2011 09:49:36 +0200
Message-ID: <CAOJsxLFXy7-u+G_MLUnD3+kYqxsbns4dQV2WEpBu2oCJ4PtT7A@mail.gmail.com>
Subject: Re: [GIT PULL] mm: frontswap (SUMMARY)
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Neo Jia <cyclonusj@gmail.com>, levinsasha928@gmail.com, JeremyFitzhardinge <jeremy@goop.org>, linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Chris Mason <chris.mason@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, ngupta@vflare.org, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Sun, Nov 6, 2011 at 9:31 PM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
> A farewell haiku:
>
> Crash test dummy folds.
> KVM mafia wins.
> Innovation cries.

Does this mean you've stopped working on frontswap or that frontswap
is dead? What does this mean for the cleancache hooks? Are they still
useful?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
