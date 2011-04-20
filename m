Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B6DD68D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 07:51:35 -0400 (EDT)
Received: by gxk23 with SMTP id 23so234545gxk.14
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 04:51:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110420112020.GA31296@parisc-linux.org>
References: <20110420102314.4604.A69D9226@jp.fujitsu.com>
	<BANLkTi=mxWwLPEnB+rGg29b06xNUD0XvsA@mail.gmail.com>
	<20110420161615.462D.A69D9226@jp.fujitsu.com>
	<BANLkTimfpY3gq8oY6bPDajBW7JN6Hp+A0A@mail.gmail.com>
	<20110420112020.GA31296@parisc-linux.org>
Date: Wed, 20 Apr 2011 14:28:26 +0300
Message-ID: <BANLkTim+m-v-4k17HUSOYSbmNFDtJTgD6g@mail.gmail.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to expand_upwards
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>

Hi Matthew,

On Wed, Apr 20, 2011 at 10:34:23AM +0300, Pekka Enberg wrote:
>> That part makes me think the best option is to make parisc do
>> CONFIG_NUMA as well regardless of the historical intent was.

On Wed, Apr 20, 2011 at 2:20 PM, Matthew Wilcox <matthew@wil.cx> wrote:
> But it's not just parisc. =A0It's six other architectures as well, some
> of which aren't even SMP. =A0Does !SMP && NUMA make any kind of sense?

IIRC, we actually fixed SLAB or SLUB to work on such configs in the past.

On Wed, Apr 20, 2011 at 2:20 PM, Matthew Wilcox <matthew@wil.cx> wrote:
> I think really, this is just a giant horrible misunderstanding on the par=
t
> of the MM people. =A0There's no reason why an ARM chip with 16MB of memor=
y
> at 0 and 16MB of memory at 1GB should be saddled with all the NUMA gunk.

Right. My point was simply that since x86 doesn't support DISCONTIGMEM
without NUMA, the misunderstanding is likely very wide-spread.

                       Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
