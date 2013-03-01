Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id C92916B0002
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 20:30:43 -0500 (EST)
Received: by mail-oa0-f44.google.com with SMTP id h1so4881268oag.17
        for <linux-mm@kvack.org>; Thu, 28 Feb 2013 17:30:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBBtCxBgoeJ8xcj4zqv7pEk7uAy39V=in4RppDH05GjPkA@mail.gmail.com>
References: <512B677D.1040501@oracle.com> <CAHGf_=rur29gFs9R9AYeDwnbVBm3b3cOfAn2xyi=mQ+ZbgzEDA@mail.gmail.com>
 <512C15F0.6030907@oracle.com> <CAJd=RBBxTutPsF+XPZGt44eT1f0uPAQfCvQj_UmwdDg82J=F+A@mail.gmail.com>
 <CAHGf_=r5oo+N0_BSd-8-GPeburBnHVAjLEszmNkj+ASMJXqYLQ@mail.gmail.com> <CAJd=RBBtCxBgoeJ8xcj4zqv7pEk7uAy39V=in4RppDH05GjPkA@mail.gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 28 Feb 2013 20:30:22 -0500
Message-ID: <CAHGf_=pFebzif0CZs1bt0kXE+F9Y79pO8XWe0VLnAO4iTbPrcA@mail.gmail.com>
Subject: Re: mm: BUG in mempolicy's sp_insert
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Feb 28, 2013 at 1:53 AM, Hillf Danton <dhillf@gmail.com> wrote:
> On Thu, Feb 28, 2013 at 1:26 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
>>> Insert new node after updating node in tree.
>>
>> Thanks. you are right. I could reproduce and verified.
>
> Thank you too;) pleasure to do minor work for you.
>
> btw, how about your belly now? fully recovered?

Yup. I could learned US health care a bit. =)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
