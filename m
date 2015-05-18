Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 16D8B6B0032
	for <linux-mm@kvack.org>; Mon, 18 May 2015 14:36:21 -0400 (EDT)
Received: by wicnf17 with SMTP id nf17so79276272wic.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 11:36:20 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id s1si14068100wiy.52.2015.05.18.11.36.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 11:36:19 -0700 (PDT)
Received: by wicmx19 with SMTP id mx19so89804353wic.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 11:36:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <28901.1431962436@warthog.procyon.org.uk>
References: <CALq1K=KSkPB9LY__rh04ic_rv2H0rGCLNfeKoY-+U2=EF32sBg@mail.gmail.com>
 <7254.1431945085@warthog.procyon.org.uk> <CALq1K=J4iRqD5qiSr2S7m+jgr63K7=e1PmA-pX1s4MEDimsLbw@mail.gmail.com>
 <23799.1431955741@warthog.procyon.org.uk> <CALq1K=KTGd5Xdj88PmQM3H3aSpakLbUdG=usi+7g9zmN+Ms4Xw@mail.gmail.com>
 <28901.1431962436@warthog.procyon.org.uk>
From: Leon Romanovsky <leon@leon.nu>
Date: Mon, 18 May 2015 21:35:58 +0300
Message-ID: <CALq1K=+DL3n1_GNCJYNBQ+n7gGhSzTzpJKxSJvRWn+pJMrvnrA@mail.gmail.com>
Subject: Re: [RFC] Refactor kenter/kleave/kdebug macros
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-cachefs <linux-cachefs@redhat.com>, linux-afs <linux-afs@lists.infradead.org>

On Mon, May 18, 2015 at 6:20 PM, David Howells <dhowells@redhat.com> wrote:
> Leon Romanovsky <leon@leon.nu> wrote:
>
>> >> Additionally, It looks like the output of these macros can be viewed by
>> >> ftrace mechanism.
>> >
>> > *blink* It can?
>> I was under strong impression that "function" and "function_graph"
>> tracers will give similar kenter/kleave information. Do I miss
>> anything important, except the difference in output format?
>>
>> >
>> >> Maybe we should delete them from mm/nommu.c as was pointed by Joe?
>> >
>> > Why?
>> If ftrace is sufficient to get the debug information, there will no
>> need to duplicate it.
>
> It isn't sufficient.  It doesn't store the parameters or the return value, it
> doesn't distinguish the return path in a function when there's more than one,
> eg.:
>
>                 kleave(" = %d [val]", ret);
>
> vs:
>
>         kleave(" = %lx", result);
>
> in do_mmap_pgoff() and it doesn't permit you to retrieve data from where the
> argument pointers that you don't have pointed to, eg.:
>
>         kenter("%p{%d}", region, region->vm_usage);
>
> David
Thanks you for explanation, I'll send the patch in near future.


-- 
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
