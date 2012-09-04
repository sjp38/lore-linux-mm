Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 1585D6B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 05:44:22 -0400 (EDT)
Received: by iagk10 with SMTP id k10so10998701iag.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 02:44:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1346750545-2094-1-git-send-email-luisgf@gmail.com>
References: <1346750545-2094-1-git-send-email-luisgf@gmail.com>
Date: Tue, 4 Sep 2012 06:44:21 -0300
Message-ID: <CALF0-+WgGPT=x93a3p1TKL8w_kNhXPACXMWrPGF2tmBnnQKCWw@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm: Fix unused function warnings in vmstat.c
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luis Gonzalez Fernandez <luisgf@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org

Hi Luis,


On Tue, Sep 4, 2012 at 6:22 AM, Luis Gonzalez Fernandez
<luisgf@gmail.com> wrote:
> frag_start(), frag_next(), frag_stop(), walk_zones_in_node() throws
> compilation warnings (-Wunused-function) even when are currently used.
>

This is very odd. I don't get that warning, and (as you said) there's
no reason to get it,
since those functions are used.

What compiler are you using?

Thanks,
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
