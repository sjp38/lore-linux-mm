Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 894696B0003
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 12:45:28 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id u5so8518713ota.1
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 09:45:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x93sor13163491ota.13.2018.11.13.09.45.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 09:45:27 -0800 (PST)
Received: from mail-ot1-f54.google.com (mail-ot1-f54.google.com. [209.85.210.54])
        by smtp.gmail.com with ESMTPSA id s187-v6sm7464959oie.13.2018.11.13.09.45.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 09:45:24 -0800 (PST)
Received: by mail-ot1-f54.google.com with SMTP id a11so8464576otr.10
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 09:45:24 -0800 (PST)
MIME-Version: 1.0
References: <d45addefdf05b84af96fb494d52b4ec4@natalenko.name>
 <CAGqmi77Ok0usUt5gfyPMYx22FdgqntSrwiap7=DT81HZuvNm_Q@mail.gmail.com> <5a9ef9a0c8ed688e1566fc7380915837@natalenko.name>
In-Reply-To: <5a9ef9a0c8ed688e1566fc7380915837@natalenko.name>
From: Timofey Titovets <timofey.titovets@synesis.ru>
Date: Tue, 13 Nov 2018 20:44:47 +0300
Message-ID: <CAGqmi75sDjHRT0efM4RW06UQEXvfneGoOtahidbk_jaSMzXCxw@mail.gmail.com>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleksandr@natalenko.name
Cc: linux-doc@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>

=D0=B2=D1=82, 13 =D0=BD=D0=BE=D1=8F=D0=B1. 2018 =D0=B3. =D0=B2 20:27, Oleks=
andr Natalenko <oleksandr@natalenko.name>:
>
> On 13.11.2018 18:10, Timofey Titovets wrote:
> > You mean try do something, like that right?
> >
> > read_lock(&tasklist_lock);
> >   <get reference to task>
> >   task_lock(task);
> > read_unlock(&tasklist_lock);
> >     last_pid =3D task_pid_nr(task);
> >     ksm_import_task_vma(task);
> >   task_unlock(task);
>
> No, task_lock() uses spin_lock() under the bonnet, so this will be the
> same.
>
> Since the sole reason you have to lock/acquire/get a reference to
> task_struct here is to prevent it from disappearing, I was thinking
> about using get_task_struct(), which just increases atomic
> task_struct.usage value (IOW, takes a reference). I *hope* this will be
> enough to prevent task_struct from disappearing in the meantime.
>
> Someone, correct me if I'm wrong.

That brilliant, i just missing that api.
That must do exactly what i want.

Thanks!

> --
>    Oleksandr Natalenko (post-factum)
>
