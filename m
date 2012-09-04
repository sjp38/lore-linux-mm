Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 4FA986B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 05:51:43 -0400 (EDT)
Received: by obhx4 with SMTP id x4so13151098obh.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 02:51:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALF0-+WgGPT=x93a3p1TKL8w_kNhXPACXMWrPGF2tmBnnQKCWw@mail.gmail.com>
References: <1346750545-2094-1-git-send-email-luisgf@gmail.com> <CALF0-+WgGPT=x93a3p1TKL8w_kNhXPACXMWrPGF2tmBnnQKCWw@mail.gmail.com>
From: "Luis G.F" <luisgf@gmail.com>
Date: Tue, 4 Sep 2012 11:51:22 +0200
Message-ID: <CAHve1mzGvzrvu+QTgUg0FAFOuQrhcY12H3LfMjCHJKBUrK0OhA@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm: Fix unused function warnings in vmstat.c
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org

Hi Ezequiel:

I'm using GCC 4.6.3

2012/9/4 Ezequiel Garcia <elezegarcia@gmail.com>:
> Hi Luis,
>
>
> On Tue, Sep 4, 2012 at 6:22 AM, Luis Gonzalez Fernandez
> <luisgf@gmail.com> wrote:
>> frag_start(), frag_next(), frag_stop(), walk_zones_in_node() throws
>> compilation warnings (-Wunused-function) even when are currently used.
>>
>
> This is very odd. I don't get that warning, and (as you said) there's
> no reason to get it,
> since those functions are used.
>
> What compiler are you using?
>
> Thanks,
> Ezequiel.



-- 

--
Luis Gonzalez Fernandez
Telf: 661772374
E-Mail: luisgf@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
