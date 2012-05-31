Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id EC4B96B0062
	for <linux-mm@kvack.org>; Thu, 31 May 2012 03:50:46 -0400 (EDT)
Received: by yenm7 with SMTP id m7so715594yen.14
        for <linux-mm@kvack.org>; Thu, 31 May 2012 00:50:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHGf_=rT+X9PpJhfr=1GdRQ-5GALUHbt3txJCMDnus_C7Pkcug@mail.gmail.com>
References: <1336431315-29736-1-git-send-email-andi@firstfloor.org>
	<1338429749-5780-1-git-send-email-tdmackey@twitter.com>
	<20120531042249.GG9850@tassilo.jf.intel.com>
	<CAHGf_=rT+X9PpJhfr=1GdRQ-5GALUHbt3txJCMDnus_C7Pkcug@mail.gmail.com>
Date: Thu, 31 May 2012 10:50:45 +0300
Message-ID: <CAOJsxLFmoh6OCtJmFdKdYLGF5j4GD_N8oxR=A6NF_DHVSCBAUg@mail.gmail.com>
Subject: Re: [PATCH v4] slab/mempolicy: always use local policy from interrupt context
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andi Kleen <ak@linux.intel.com>, David Mackey <tdmackey@twitter.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux.com, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, May 31, 2012 at 12:22 AM, Andi Kleen <ak@linux.intel.com> wrote:
>>> [tdmackey@twitter.com: Rework patch logic and avoid dereference of curr=
ent
>>> task if in interrupt context.]
>>
>> avoiding this reference doesn't make sense, it's totally valid.
>> This is based on a older version. I sent the fixed one some time ago.

On Thu, May 31, 2012 at 7:59 AM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
> Where? I think David's version is most cleaner one.
>
> =A0Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Monsieur Lameter, Monsieur Rientjes, ACK/NAK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
