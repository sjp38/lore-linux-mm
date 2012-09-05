Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 82DCC6B0068
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 02:54:33 -0400 (EDT)
Received: by iagk10 with SMTP id k10so381066iag.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 23:54:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120904141235.dd9a3e39.akpm@linux-foundation.org>
References: <1346750545-2094-1-git-send-email-luisgf@gmail.com>
 <CALF0-+WgGPT=x93a3p1TKL8w_kNhXPACXMWrPGF2tmBnnQKCWw@mail.gmail.com>
 <CAHve1mzGvzrvu+QTgUg0FAFOuQrhcY12H3LfMjCHJKBUrK0OhA@mail.gmail.com>
 <CALF0-+XNXNWm7qQ3vZRrN1cd89hCowDiJgTn7Ty80FBRsqB=4g@mail.gmail.com> <20120904141235.dd9a3e39.akpm@linux-foundation.org>
From: "Luis G.F" <luisgf@gmail.com>
Date: Wed, 5 Sep 2012 08:54:11 +0200
Message-ID: <CAHve1myEUVa4AF_1tijpnCBBy=qcP+U5YQDRcCzvv7cPMeLiqA@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm: Fix unused function warnings in vmstat.c
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, linux-mm@kvack.org

Hi Andrew:

2012/9/4 Andrew Morton <akpm@linux-foundation.org>:
> On Tue, 4 Sep 2012 07:01:20 -0300
> Ezequiel Garcia <elezegarcia@gmail.com> wrote:
>
>> Also, in the future when fixing warnings you may want to add the warning message
>> to the commit message.
>
> Yes, please always quote the messages in the changelog.
>
>> Anyway, I don't really know why are you getting that (wrong) warning,
>> but I don't think the solution is to add the 'unused' attribute.
>
> And yes, let's not work around compiler problems too eagerly.  We _do_
> occasionally work around bogus warnings, but only long-established ones
> which we see no other way of fixing.
>
> In this case, it might be that these functions are indeed unused with
> certain Kconfig combinations.  For example and from inspection,
> CONFIG_PROCFS=n, CONFIG_DEBUG_FS=n, CONFIG_COMPACTION=y might cause
> such a warning?
>

I generate a complete random conf (with make randconfig) and the
problem with warnings is that
CONFIG_PROC_FS is undefined but CONFIG_COMPACTION=y (as you say).That's create
certain scenario where the variables are defined but never used.


> Also, please don't directly use __attribute__((unused)) - we have
> various helper macros in include/linux/compiler*.h for this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
