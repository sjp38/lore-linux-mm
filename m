Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id AB3356B00B0
	for <linux-mm@kvack.org>; Sat,  8 Sep 2012 18:45:52 -0400 (EDT)
Received: by iagk10 with SMTP id k10so857520iag.14
        for <linux-mm@kvack.org>; Sat, 08 Sep 2012 15:45:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <00000139a801aba3-4616277c-d845-4b62-83ec-1a1950b05751-000000@email.amazonses.com>
References: <CALF0-+VMtUPuLHg3CwDxFm-TjbN1=YavGO79Oo3GuymOLvikeA@mail.gmail.com>
	<00000139a801aba3-4616277c-d845-4b62-83ec-1a1950b05751-000000@email.amazonses.com>
Date: Sat, 8 Sep 2012 19:45:51 -0300
Message-ID: <CALF0-+U=sFgynE__V-XTN1SAgJHV_3VigRrdxuXFinbiWPg2oQ@mail.gmail.com>
Subject: Re: [PATCH v2 0/10] mm: SLxB cleaning and trace accuracy improvement
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, JoonSoo Kim <js1304@gmail.com>, Tim Bird <tim.bird@am.sony.com>, Steven Rostedt <rostedt@goodmis.org>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>

Christoph,

On Sat, Sep 8, 2012 at 7:30 PM, Christoph Lameter <cl@linux.com> wrote:
> On Sat, 8 Sep 2012, Ezequiel Garcia wrote:
>
>> This is the second spin of my patchset to clean SLxB and improve kmem
>> trace events accuracy.
>
> Please redo the patches on top of the patchsets that create
> mm/slab_common.c. You will be able to extract a lot more common code and
> help the goal of having as much common code as possible. PLease move as
> much as possible of the common functions into slab_common.c
>

Ah, I wasn't sure where to base my patches. I can split this patchset in two and
base the SLAB/SLUB commonize part on top of your tree, or perhaps just
based everything on top of your tree.

Is it this one?
http://west.gentwo.org/gitweb/?p=christoph;a=shortlog;h=refs/heads/common

I have to admit I started thinking of this commonization after seeing
your common
code patches.

Thanks!
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
