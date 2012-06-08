Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 404056B005A
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 16:23:57 -0400 (EDT)
Received: by mail-vc0-f176.google.com with SMTP id fo14so1569211vcb.35
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 13:23:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1206081514130.4213@router.home>
References: <1338405610-1788-1-git-send-email-pshelar@nicira.com>
	<20120608131045.90708bda.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1206081514130.4213@router.home>
Date: Fri, 8 Jun 2012 13:23:56 -0700
Message-ID: <CALnjE+rdvdj=XXd7iCYzL_BUGYsLQTM1mYRay+0q2iFxqiDqSw@mail.gmail.com>
Subject: Re: [Resend PATCH v2] mm: Fix slab->page _count corruption.
From: Pravin Shelar <pshelar@nicira.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, penberg@kernel.org, aarcange@redhat.com, linux-mm@kvack.org, abhide@nicira.com

On Fri, Jun 8, 2012 at 1:15 PM, Christoph Lameter <cl@linux.com> wrote:
> On Fri, 8 Jun 2012, Andrew Morton wrote:
>
>> OK. =A0I assume this bug has been there for quite some time.
>
> Well the huge pages refcount tricks caused the issue.
>
>> How serious is it? =A0Have people been reporting it in real workloads?
>> How to trigger it? =A0IOW, does this need -stable backporting?
>
> Possibly.

If this patch is getting back-ported then we shld also do same for
5bf5f03c271907978 (mm: fix slab->page flags corruption) which fixes
other issue related to slub  and huge page sharing.

>
>> Also, someone forgot to document these:
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 unsigned inuse:16;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 unsigned objects:15;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 unsigned frozen:1;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
>
> So far I thouight that the field names are pretty clear on their own.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
