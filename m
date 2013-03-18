Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 7CC376B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 18:50:54 -0400 (EDT)
Message-ID: <51479A36.3050600@zytor.com>
Date: Mon, 18 Mar 2013 15:50:30 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: mm: accurate the comments for STEP_SIZE_SHIFT macro
References: <1363602068-11924-1-git-send-email-linfeng@cn.fujitsu.com> <CAE9FiQWuSL5Vq5VaAvQg_NT2gQJr17eMNoQbxtNJ8G3wweWNHQ@mail.gmail.com> <51476402.7050102@zytor.com> <CAE9FiQUZDqqeAp2y=Pc9yFT81Pf+ei2SEx4NUD6jC+nQmd6PcA@mail.gmail.com> <514767A5.4020601@zytor.com> <CAE9FiQU2iqx=9LEx_u6J5O_kQ-5Lo6DTgSgnk71k0p6WWUa7Hg@mail.gmail.com>
In-Reply-To: <CAE9FiQU2iqx=9LEx_u6J5O_kQ-5Lo6DTgSgnk71k0p6WWUa7Hg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, penberg@kernel.org, jacob.shin@amd.com

On 03/18/2013 02:19 PM, Yinghai Lu wrote:
> On Mon, Mar 18, 2013 at 12:14 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> 
>> Instead, try to explain why 5 is the correct value in the current code
>> and how it is (or should be!) derived.
> 
> initial mapped size is PMD_SIZE, aka 2M.
> if we use step_size to be PUD_SIZE aka 1G, as most worse case
> that 1G is cross the 1G boundary, and PG_LEVEL_2M is not set,
> we will need 1+1+512 pages (aka 2M + 8k) to map 1G range with PTE.
> So i picked (30-21)/2 to get 5.
> 
> Please check attached patch.
> 
> Thanks
> 
> Yinghai
> 

This still seems very opaque.  I need to look at it and see if it makes
more sense in context.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
