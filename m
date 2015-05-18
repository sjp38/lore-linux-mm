Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 875D46B00BE
	for <linux-mm@kvack.org>; Mon, 18 May 2015 09:52:36 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so89703945wic.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 06:52:36 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id ht6si12784721wib.102.2015.05.18.06.52.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 06:52:35 -0700 (PDT)
Received: by wizk4 with SMTP id k4so80320436wiz.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 06:52:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <23799.1431955741@warthog.procyon.org.uk>
References: <CALq1K=KSkPB9LY__rh04ic_rv2H0rGCLNfeKoY-+U2=EF32sBg@mail.gmail.com>
 <7254.1431945085@warthog.procyon.org.uk> <CALq1K=J4iRqD5qiSr2S7m+jgr63K7=e1PmA-pX1s4MEDimsLbw@mail.gmail.com>
 <23799.1431955741@warthog.procyon.org.uk>
From: Leon Romanovsky <leon@leon.nu>
Date: Mon, 18 May 2015 16:52:13 +0300
Message-ID: <CALq1K=KTGd5Xdj88PmQM3H3aSpakLbUdG=usi+7g9zmN+Ms4Xw@mail.gmail.com>
Subject: Re: [RFC] Refactor kenter/kleave/kdebug macros
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-cachefs <linux-cachefs@redhat.com>, linux-afs <linux-afs@lists.infradead.org>

On Mon, May 18, 2015 at 4:29 PM, David Howells <dhowells@redhat.com> wrote:
> Leon Romanovsky <leon@leon.nu> wrote:
>
>> Blind conversion to pr_debug will blow the code because it will be always
>> compiled in.
>
> No, it won't.
Sorry, you are right.

>
>> Additionally, It looks like the output of these macros can be viewed by ftrace
>> mechanism.
>
> *blink* It can?
I was under strong impression that "function" and "function_graph"
tracers will give similar kenter/kleave information. Do I miss
anything important, except the difference in output format?

>
>> Maybe we should delete them from mm/nommu.c as was pointed by Joe?
>
> Why?
If ftrace is sufficient to get the debug information, there will no
need to duplicate it.

>
> David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
