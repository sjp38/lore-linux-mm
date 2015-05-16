Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB7C6B0073
	for <linux-mm@kvack.org>; Sat, 16 May 2015 14:57:15 -0400 (EDT)
Received: by wibt6 with SMTP id t6so27340515wib.0
        for <linux-mm@kvack.org>; Sat, 16 May 2015 11:57:14 -0700 (PDT)
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id vf7si9212850wjc.127.2015.05.16.11.57.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 May 2015 11:57:13 -0700 (PDT)
Received: by wgin8 with SMTP id n8so147912992wgi.0
        for <linux-mm@kvack.org>; Sat, 16 May 2015 11:57:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1431796166.15709.81.camel@perches.com>
References: <CALq1K=KSkPB9LY__rh04ic_rv2H0rGCLNfeKoY-+U2=EF32sBg@mail.gmail.com>
 <1431796166.15709.81.camel@perches.com>
From: Leon Romanovsky <leon@leon.nu>
Date: Sat, 16 May 2015 21:56:52 +0300
Message-ID: <CALq1K=+X-Gk8xEaMVT0VWujz1pc45+6DsugWiaCPeF-zObozLg@mail.gmail.com>
Subject: Re: [RFC] Refactor kenter/kleave/kdebug macros
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: dhowells <dhowells@redhat.com>, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-cachefs <linux-cachefs@redhat.com>, linux-afs <linux-afs@lists.infradead.org>

On Sat, May 16, 2015 at 8:09 PM, Joe Perches <joe@perches.com> wrote:
> On Sat, 2015-05-16 at 20:01 +0300, Leon Romanovsky wrote:
[]
>> My question is how we should handle such duplicated debug print code?
>> As possible solutions, I see five options:
>> 1. Leave it as is.
>> 2. Move it to general include file (for example linux/printk.h) and
>> commonize the output to be consistent between different kdebug users.
>> 3. Add CONFIG_*_DEBUG definition for every kdebug user.
>> 4. Move everything to "#if 0" construction.
>> 5. Move everything to "#if defined(__KDEBUG)" construction.
>
> 6: delete the macros and uses
Thank you, It is indeed possible option, since in last six years there
were no attempts to "open" this code.


-- 
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
