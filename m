Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2857F6B000D
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 19:17:19 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id f8-v6so13993954qtb.23
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 16:17:19 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id i63-v6si152256qkc.177.2018.06.25.16.17.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jun 2018 16:17:18 -0700 (PDT)
Reply-To: crecklin@redhat.com
Subject: Re: [PATCH] add param that allows bootline control of hardened
 usercopy
References: <1529939300-27461-1-git-send-email-crecklin@redhat.com>
 <d110c9af-cb68-5a3c-bc70-0c7650edb0d4@redhat.com>
 <cfd52ae6-6fea-1a5a-b2dd-4dfdd65acd15@redhat.com>
 <2e4d9686-835c-f4be-2647-2344899e3cd4@redhat.com>
 <CAGXu5jJGqxKjcWGyAnbkmFebtPor0PEQ+2qpoMCGtjjdYRTHDw@mail.gmail.com>
From: Christoph von Recklinghausen <crecklin@redhat.com>
Message-ID: <53edba5a-1652-d1c2-12c9-7f3cda746f5f@redhat.com>
Date: Mon, 25 Jun 2018 19:17:16 -0400
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJGqxKjcWGyAnbkmFebtPor0PEQ+2qpoMCGtjjdYRTHDw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 06/25/2018 06:35 PM, Kees Cook wrote:
> On Mon, Jun 25, 2018 at 3:29 PM, Christoph von Recklinghausen
> <crecklin@redhat.com> wrote:
>> I have a small set of customers that want CONFIG_HARDENED_USERCOPY
>> enabled, and a large number of customers who would be impacted by its
>> default behavior (before my change).  The desire was to have the smaller
>> number of users need to change their boot lines to get the behavior they
>> wanted. Adding CONFIG_HUC_DEFAULT_OFF was an attempt to preserve the
>> default behavior of existing users of CONFIG_HARDENED_USERCOPY (default
>> enabled) and allowing that to coexist with the desires of the greater
>> number of my customers (default disabled).
>>
>> If folks think that it's better to have it enabled by default and the
>> command line option to turn it off I can do that (it is simpler). Does
>> anyone else have opinions one way or the other?
> I would prefer to isolate the actual problem case, and fix it if
> possible. (i.e. try to make the copy fixed-length, etc) Barring that,
> yes, a kernel command line to disable the protection would be okay.
>
> Note that the test needs to be inside __check_object_size() otherwise
> the inline optimization with __builtin_constant_p() gets broken and
> makes everyone slower. :)
>
> -Kees
>
Thanks Kees,

I'll make that change and retest.

Chris
