Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 398A78E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 11:01:43 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id h10-v6so2216965ybm.3
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 08:01:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 9-v6sor3002815yby.44.2018.09.21.08.01.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 08:01:41 -0700 (PDT)
MIME-Version: 1.0
From: Chulmin Kim <cmkim.laika@gmail.com>
Date: Sat, 22 Sep 2018 00:01:30 +0900
Message-ID: <CANYKp7ufttxsNkewBqgYDexMAoyVnMxgoy-EydCqmHadxyn+QQ@mail.gmail.com>
Subject: Question about a pte with PTE_PROT_NONE and !PTE_VALID on !PROT_NONE vma
Content-Type: multipart/alternative; boundary="000000000000be7814057662ea05"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

--000000000000be7814057662ea05
Content-Type: text/plain; charset="UTF-8"

Hi all.
I am developing an android smartphone.

I am facing a problem that a thread is looping the page fault routine
forever.
(The kernel version is around v4.4 though it may differ from the mainline
slightly
as the problem occurs in a device being developed in my company.)

The pte corresponding to the fault address is with PTE_PROT_NONE and
!PTE_VALID.
(by the way, the pte is mapped to anon page (ashmem))
The weird thing, in my opinion, is that
the VMA of the fault address is not with PROT_NONE but with PROT_READ &
PROT_WRITE.
So, the page fault routine (handle_pte_fault()) returns 0 and fault loops
forever.

I don't think this is a normal situation.

As I didn't enable NUMA, a pte with PROT_NONE and !PTE_VALID is likely set
by mprotect().
1. mprotect(PROT_NONE) -> vma split & set pte with PROT_NONE
2. mprotect(PROT_READ & WRITE) -> vma merge & revert pte
I suspect that the revert pte in #2 didn't work somehow
but no clue.

I googled and found a similar situation (
http://linux-kernel.2935.n7.nabble.com/pipe-page-fault-oddness-td953839.html)
which is relevant to NUMA and huge pagetable configs
while my device is nothing to do with those configs.

Am I missing any possible scenario? or is it already known BUG?
It will be pleasure if you can give any idea about this problem.

Thanks.
Chulmin Kim

--000000000000be7814057662ea05
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr">Hi all.<div>I am developing an android sm=
artphone.</div><div><br></div><div>I am facing a problem that a thread is l=
ooping the page fault routine forever.<br></div><div>(The kernel version is=
 around v4.4 though it may differ from the mainline slightly=C2=A0</div><di=
v>as the problem occurs in a device being developed in my company.)</div><d=
iv><br></div><div>The pte corresponding to the fault address is with PTE_PR=
OT_NONE and !PTE_VALID.</div><div>(by the way, the pte is mapped to anon pa=
ge (ashmem))</div><div>The weird thing, in my opinion, is that</div><div>th=
e VMA of the fault address is not with=C2=A0PROT_NONE=C2=A0but with PROT_RE=
AD &amp; PROT_WRITE.</div><div>So, the page fault routine (handle_pte_fault=
()) returns 0 and fault loops forever.</div><div><br></div><div>I don&#39;t=
 think this is a normal situation.</div><div><br></div><div>As I didn&#39;t=
 enable NUMA, a pte with PROT_NONE and !PTE_VALID is likely set by mprotect=
().</div><div>1. mprotect(PROT_NONE) -&gt; vma split &amp; set pte with PRO=
T_NONE</div><div>2. mprotect(PROT_READ &amp; WRITE) -&gt; vma merge &amp; r=
evert pte=C2=A0</div><div>I suspect that the revert pte in #2 didn&#39;t wo=
rk somehow</div><div>but no clue.</div><div><br></div><div>I googled and fo=
und a similar situation (<a href=3D"http://linux-kernel.2935.n7.nabble.com/=
pipe-page-fault-oddness-td953839.html">http://linux-kernel.2935.n7.nabble.c=
om/pipe-page-fault-oddness-td953839.html</a>) which is relevant to NUMA and=
 huge pagetable configs</div><div>while my device is nothing to do with tho=
se configs.</div><div><br></div><div>Am I missing any possible scenario? or=
 is it already known BUG?<br></div><div>It will be pleasure if you can give=
 any idea about this problem.<br></div><div><br></div><div>Thanks.</div><di=
v>Chulmin Kim</div></div></div>

--000000000000be7814057662ea05--
