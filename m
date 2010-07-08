Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B67F86B0071
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 07:23:28 -0400 (EDT)
Subject: Re: FYI: mmap_sem OOM patch
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100708200324.CD4B.A69D9226@jp.fujitsu.com>
References: <20100708195421.CD48.A69D9226@jp.fujitsu.com>
	 <1278586921.1900.67.camel@laptop>
	 <20100708200324.CD4B.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 08 Jul 2010 13:23:20 +0200
Message-ID: <1278588200.1900.89.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Michel Lespinasse <walken@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Divyesh Shah <dpshah@google.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-07-08 at 20:06 +0900, KOSAKI Motohiro wrote:
> > [ small note on that we really should kill __GFP_NOFAIL, its utter
> > deadlock potential ]
>=20
> I disagree. __GFP_NOFAIL mean this allocation failure can makes really
> dangerous result. Instead, OOM-Killer should try to kill next process.
> I think.=20

Say _what_?! you think NOFAIL is a sane thing? Pretty much everybody has
been agreeing for years that the thing should die.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
