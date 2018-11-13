Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 81E0B6B0007
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 12:59:35 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id s19so32224986qke.20
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 09:59:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v7sor13902018qvl.52.2018.11.13.09.59.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 09:59:33 -0800 (PST)
Date: Tue, 13 Nov 2018 17:59:30 +0000
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Message-ID: <20181113175930.3g65rlhbaimstq7g@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
References: <CAG48ez0ZprqUYGZFxcrY6U3Dnwt77q1NJXzzpsn1XNkRuXVppw@mail.gmail.com>
 <d43da6ad1a3c164aa03e0f22f065591a@natalenko.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d43da6ad1a3c164aa03e0f22f065591a@natalenko.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleksandr Natalenko <oleksandr@natalenko.name>
Cc: jannh@google.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, timofey.titovets@synesis.ru, willy@infradead.org

On 18-11-13 15:23:50, Oleksandr Natalenko wrote:
> Hi.
> 
> > Yep. However, so far, it requires an application to explicitly opt in
> > to this behavior, so it's not all that bad. Your patch would remove
> > the requirement for application opt-in, which, in my opinion, makes
> > this way worse and reduces the number of applications for which this
> > is acceptable.
> 
> The default is to maintain the old behaviour, so unless the explicit
> decision is made by the administrator, no extra risk is imposed.

The new interface would be more tolerable if it honored MADV_UNMERGEABLE:

KSM default on: merge everything except when MADV_UNMERGEABLE is
excplicitly set.

KSM default off: merge only when MADV_MERGEABLE is set.

The proposed change won't honor MADV_UNMERGEABLE, meaning that
application programmers won't have a way to prevent sensitive data to be
every merged. So, I think, we should keep allow an explicit opt-out
option for applications.

> 
> > As far as I know, basically nobody is using KSM at this point. There
> > are blog posts from several cloud providers about these security risks
> > that explicitly state that they're not using memory deduplication.
> 
> I tend to disagree here. Based on both what my company does and what UKSM
> users do, memory dedup is a desired option (note "option" word here, not the
> default choice).

Lightweight containers is a use case for KSM: when many VMs share the
same small kernel. KSM is used in production by large cloud vendors.

Thank you,
Pasha
