Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 593BC6B0062
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:49:05 -0400 (EDT)
Received: by yenm7 with SMTP id m7so3775726yen.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 13:49:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1206111336370.4552@chino.kir.corp.google.com>
References: <1339422650-9798-1-git-send-email-kosaki.motohiro@gmail.com>
 <alpine.DEB.2.00.1206110856180.31180@router.home> <4FD60127.1000805@jp.fujitsu.com>
 <alpine.DEB.2.00.1206111336370.4552@chino.kir.corp.google.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 11 Jun 2012 16:48:43 -0400
Message-ID: <CAHGf_=rbss0RsoFn7NZ7oFCpCZuEYkPDXaHSW4KHg=Vu8703xA@mail.gmail.com>
Subject: Re: [PATCH] mm: fix protection column misplacing in /proc/zoneinfo
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: cl@linux.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 11, 2012 at 4:37 PM, David Rientjes <rientjes@google.com> wrote:
> On Mon, 11 Jun 2012, KOSAKI Motohiro wrote:
>
>> > You are not worried about breaking something that may scan the zoneinfo
>> > output with this change? Its been this way for 6 years and its likely that
>> > tools expect the current layout.
>>
>> I don't worry about this. Because of, /proc/zoneinfo is cray machine unfrinedly
>> format and afaik no application uses it.
>>
>
> We do, and I think it would be a shame to break anything parsing the way
> that this file has been written for the past several years for something
> as aesthetical as this.

How do you parsing?

Several years, some one added ZVC stat. therefore, hardcoded line
number parsing never work anyway. And in the other hand, if you are
parsing, field
name, my patch doesn't break anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
