Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2BFFC6B0003
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 17:35:35 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id h25-v6so7251355eds.21
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 14:35:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x30-v6sor10858216ede.20.2018.11.13.14.35.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 14:35:33 -0800 (PST)
MIME-Version: 1.0
References: <CAG48ez0ZprqUYGZFxcrY6U3Dnwt77q1NJXzzpsn1XNkRuXVppw@mail.gmail.com>
 <d43da6ad1a3c164aa03e0f22f065591a@natalenko.name> <20181113175930.3g65rlhbaimstq7g@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
 <CAG48ez29kArZTU=MgsVxWbuTZZ+sCrxeQ3FkDKpmQnj_MZ5hTg@mail.gmail.com>
In-Reply-To: <CAG48ez29kArZTU=MgsVxWbuTZZ+sCrxeQ3FkDKpmQnj_MZ5hTg@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Tue, 13 Nov 2018 14:35:21 -0800
Message-ID: <CA+CK2bDPeEsFwGAQf7f=YQ+s6aUTm-ApgFd2RR5JQQr-pi-aqg@mail.gmail.com>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Oleksandr Natalenko <oleksandr@natalenko.name>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Timofey Titovets <timofey.titovets@synesis.ru>, Matthew Wilcox <willy@infradead.org>, daniel@gruss.cc

> Wait, what? Can you name specific ones? Nowadays, enabling KSM for
> untrusted VMs seems like a terrible idea to me, security-wise.

Of course it is not used to share data among different
customers/tenants, as far as I know it is used by Oracle Cloud to
merge the same pages in clear containers.

https://medium.com/cri-o/intel-clear-containers-and-cri-o-70824fb51811
One performance enhancing feature is the use of KSM, a recent KVM
optimized for memory sharing and boot speed. Another is the use of an
optimized Clear Containers mini-OS.

Pasha
