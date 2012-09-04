Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 6888A6B0068
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 06:01:21 -0400 (EDT)
Received: by iagk10 with SMTP id k10so11016607iag.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 03:01:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHve1mzGvzrvu+QTgUg0FAFOuQrhcY12H3LfMjCHJKBUrK0OhA@mail.gmail.com>
References: <1346750545-2094-1-git-send-email-luisgf@gmail.com>
	<CALF0-+WgGPT=x93a3p1TKL8w_kNhXPACXMWrPGF2tmBnnQKCWw@mail.gmail.com>
	<CAHve1mzGvzrvu+QTgUg0FAFOuQrhcY12H3LfMjCHJKBUrK0OhA@mail.gmail.com>
Date: Tue, 4 Sep 2012 07:01:20 -0300
Message-ID: <CALF0-+XNXNWm7qQ3vZRrN1cd89hCowDiJgTn7Ty80FBRsqB=4g@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm: Fix unused function warnings in vmstat.c
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis G.F" <luisgf@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org

Hi Luis,

On Tue, Sep 4, 2012 at 6:51 AM, Luis G.F <luisgf@gmail.com> wrote:
> Hi Ezequiel:
>
> I'm using GCC 4.6.3
>

Please, avoid top posting as it makes very difficult to follow the discussion
(and people around here hate it).

Also, in the future when fixing warnings you may want to add the warning message
to the commit message.

Anyway, I don't really know why are you getting that (wrong) warning,
but I don't think the solution is to add the 'unused' attribute.

Hope this helps,
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
