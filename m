Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1C9186B0256
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 11:15:02 -0400 (EDT)
Received: by ykdg206 with SMTP id g206so155559677ykd.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:15:01 -0700 (PDT)
Received: from mail-yk0-x22f.google.com (mail-yk0-x22f.google.com. [2607:f8b0:4002:c07::22f])
        by mx.google.com with ESMTPS id g1si6553466ywf.169.2015.09.14.08.15.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 08:15:01 -0700 (PDT)
Received: by ykft14 with SMTP id t14so3843148ykf.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:15:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAEqaY8cE7C2UvQP5x6VswOG46Gn+W+NYzWvFyqwXSjLaaTZBJg@mail.gmail.com>
References: <CAEqaY8cE7C2UvQP5x6VswOG46Gn+W+NYzWvFyqwXSjLaaTZBJg@mail.gmail.com>
Date: Mon, 14 Sep 2015 08:15:00 -0700
Message-ID: <CAA25o9Quzq-Kmr47FhKXOR_PHr-5qVH0Che2vFRXeT2vZjAKqw@mail.gmail.com>
Subject: Re: how can I solve this grep problem
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?=C3=96zkan_Pakdil?= <ozkan.pakdil@gmail.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>

On Sun, Sep 13, 2015 at 8:20 PM, =C3=96zkan Pakdil <ozkan.pakdil@gmail.com>=
 wrote:
> Hello
>
> I was searching some strings in my disk yes I mean whole disk like this
>
> find / -type f -exec grep -sl "access denied" {} \;

This is a bad idea on many levels.

1. This is the wrong list for such requests and you're lucky to get any rep=
ly.
2. You were searching for 40 hours.  You should optimize the search,
and narrow it down.  Do this instead:

find <list-of-directories> -type f | xargs grep -sl "access denied"

where <list-of-directories> excludes /sys, /proc, /dev and other
directories that it might not make sense to search.

Good luck! :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
