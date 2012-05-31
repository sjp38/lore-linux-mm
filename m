Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 7D5AC6B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 00:59:21 -0400 (EDT)
Received: by ggm4 with SMTP id 4so641607ggm.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 21:59:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120531042249.GG9850@tassilo.jf.intel.com>
References: <1336431315-29736-1-git-send-email-andi@firstfloor.org>
 <1338429749-5780-1-git-send-email-tdmackey@twitter.com> <20120531042249.GG9850@tassilo.jf.intel.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 31 May 2012 00:59:00 -0400
Message-ID: <CAHGf_=rT+X9PpJhfr=1GdRQ-5GALUHbt3txJCMDnus_C7Pkcug@mail.gmail.com>
Subject: Re: [PATCH v4] slab/mempolicy: always use local policy from interrupt context
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: David Mackey <tdmackey@twitter.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, cl@linux.com

On Thu, May 31, 2012 at 12:22 AM, Andi Kleen <ak@linux.intel.com> wrote:
>> [tdmackey@twitter.com: Rework patch logic and avoid dereference of current
>> task if in interrupt context.]
>
> avoiding this reference doesn't make sense, it's totally valid.
> This is based on a older version. I sent the fixed one some time ago.

Where? I think David's version is most cleaner one.

 Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
