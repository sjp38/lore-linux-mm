Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 078756B009D
	for <linux-mm@kvack.org>; Sat,  3 Oct 2009 15:15:13 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id n93JFSmh015488
	for <linux-mm@kvack.org>; Sat, 3 Oct 2009 12:15:28 -0700
Received: from pxi9 (pxi9.prod.google.com [10.243.27.9])
	by wpaz37.hot.corp.google.com with ESMTP id n93JFDgc000689
	for <linux-mm@kvack.org>; Sat, 3 Oct 2009 12:15:26 -0700
Received: by pxi9 with SMTP id 9so1987235pxi.4
        for <linux-mm@kvack.org>; Sat, 03 Oct 2009 12:15:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2f11576a0910030505w5a1289ebu78cdc3587caddc82@mail.gmail.com>
References: <20091002173635.5F6C.A69D9226@jp.fujitsu.com>
	 <20091002173955.5F72.A69D9226@jp.fujitsu.com>
	 <6599ad830910021501s66cfc108r9a109b84b0f658a4@mail.gmail.com>
	 <2f11576a0910030505w5a1289ebu78cdc3587caddc82@mail.gmail.com>
Date: Sat, 3 Oct 2009 12:15:25 -0700
Message-ID: <6599ad830910031215o293687ceyd8177cb1c34a41b@mail.gmail.com>
Subject: Re: [PATCH 3/3] cgroup: fix strstrip() abuse
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sat, Oct 3, 2009 at 5:05 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> Thanks - although I think I'd s/abuse/misuse/ in the description.
>
> I don't know what's different between them. My dictionary is slightly quiet ;)
> Is this X-rated word? if so, I'll resend it soon.

Certainly not X-rated :-)

Generally "abuse" carries a connotation of intent (or perhaps
deliberate hackiness) whereas "misuse" simply indicates that the
previous code was wrong.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
