Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82BA4C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 14:52:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C79120665
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 14:52:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iuQpUu6a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C79120665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B86E28E0003; Tue, 30 Jul 2019 10:52:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0F8E8E0001; Tue, 30 Jul 2019 10:52:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FF7B8E0003; Tue, 30 Jul 2019 10:52:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 37A728E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 10:52:18 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id t25so138811ljc.17
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 07:52:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=vLDKuH+/Y6R1wGAQGSCIi/9agKk/j9gR7pNqj2Ro2Ic=;
        b=tDpJY/U7xOXcorN3kl8/ChU8AHYY+PRCiW3rzkl3hWtkBhEIqki5GK3zn9wdZWHLTq
         HVvT6LBTpm8Vh5GrjfszodYo0Cqdo7GOcg2RjrdkLzV6Nrz3Ejwv7FFPGm4zop6dk1Yc
         n62xatKNSC/A+RzPkI2dfUBotB6xTvso5+gf+0okOmg26zm0WEzS4nHdZ9/h5vGRKxY1
         gmsI7qa2E8AuyZCe70I9AVMaVceDaRr7I/u8aJ+eUM6tYCCH9IqUj/zibSe6KPM+wMBK
         /jqYD2LkfehvdFCjZjIZ/bB47js/bUmf23yNRj9g7CTqH554KqXwR+1nKiQx5Ox9NlJk
         x7ig==
X-Gm-Message-State: APjAAAWtkSO3t6scnfxbHlqWCGZNTUsqy5kfu45XfZctXH3hf7WYWKeR
	JiziFaVHcerEXEhLmSqMZwOefmqC0VgOT8kFnoyLeubI2yAAavoSya1rKjjwn4kojFzslgAby+0
	5gn9Q3SJJSBbdd9nzJTJW/V9zOS3Zb56ES7EHA0Uzz1pIOY+OIrNjB8t4Q36/E9WF+g==
X-Received: by 2002:a2e:5b0f:: with SMTP id p15mr59335233ljb.82.1564498337317;
        Tue, 30 Jul 2019 07:52:17 -0700 (PDT)
X-Received: by 2002:a2e:5b0f:: with SMTP id p15mr59335200ljb.82.1564498336407;
        Tue, 30 Jul 2019 07:52:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564498336; cv=none;
        d=google.com; s=arc-20160816;
        b=EVSNLa1gZH6uN6GXiFBEHEDlhF32XNmotPpK1GFT5D1BYr/Q41NtHFEvi7nEjjlMsD
         i+g6dmGHNgDcWJ3EnWkvAY2VChsGIGfgGL9DJm7RYAiWhHFo1HNV/BTaIcZem7TzJitd
         m7eWKnGc4cqs2h2uXt2FdCByChkQYSdiFiHLHm7dSiGEDtgFSefAM7tqxKo6gjrPr7OK
         uXZD30Ya9GEEo/glLHLmqisjwiY7xlqFYWFffsYnBVkUku6iMjBW4vWspUMfslpkN2r1
         HRmy4K2WocCcoRrdqyYBLded20vlHoAA5N7iXLst4BVQMPXJKriAvkqBzb3F+6ew18tj
         5flg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=vLDKuH+/Y6R1wGAQGSCIi/9agKk/j9gR7pNqj2Ro2Ic=;
        b=U1rO2gI+2f9Cr2bvh6gGR4C+Sgyf7iFUlLIS/UkHnlsLGDViKH6qTj1B8PGkjdz1vW
         SvtBbdN/E4mTFp89S+OvGmaPqSdV+E7+sqzxDku88T9CQ2Vp62X4h97Xwsw1NUwKRHHP
         YqsnEbSMnQhOcivrf80Xq9tJVb6W33gFVfYg2mg/Hxx5gN4I8/FLgligSkbMgEO41vuB
         YHPCMUn69chKDxfGx2ExIqL/5AGUrNue7r5V2t5NRK3UEapQqkEqAu+N1fAu2MmtWhLw
         +68JmtaagPiqt4qsNAT4TBnIEb4Lmz4x5mMj5x9Z87BzpUY2poDYmR/c625x6eca+6N9
         yqQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iuQpUu6a;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v21sor16762854lfi.6.2019.07.30.07.52.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 07:52:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iuQpUu6a;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=vLDKuH+/Y6R1wGAQGSCIi/9agKk/j9gR7pNqj2Ro2Ic=;
        b=iuQpUu6a8JnbGLjoBITZrEilnUrTWiH26PXOZvr0eJQhTGXYXPQKMEzNw2wB2Zdhwg
         O1s79fuH/+qKj9qM+F5N7WUORuY3bi2XPxK5gT8Guf2uZd9D6oyAtYDwhskz/FMsfn6o
         lKk6nD1IBmzrEbMo1z8fbSNSoKGZUfXjLfcnm5mKawQB8u+vap+bsQ1AUfdjGTiXN2ty
         tL6eFXIjDfZ571OcOPQwvXVAUX+46G+xpgSdufwNKOjBmDF3XP8A7mx0CfXSR6UXqbUn
         dguHNLtM+ir+qgid1b0WJ9SI3b8hxcX2P6U5NkAvYIDJKRzUwkVnKHJszs5C7d/SjcoV
         C0AQ==
X-Google-Smtp-Source: APXvYqwtNV8PHczquSPB8e+BmF7PEr+3WvMBui8pMbhp0rAOkLkZq6TteMkvwzTbZj0eIDgOEAic/3pWWOYVMC6LbUU=
X-Received: by 2002:a19:c1cc:: with SMTP id r195mr53854149lff.95.1564498336043;
 Tue, 30 Jul 2019 07:52:16 -0700 (PDT)
MIME-Version: 1.0
References: <20190215024830.GA26477@jordon-HP-15-Notebook-PC>
 <20190728180611.GA20589@mail-itl> <CAFqt6zaMDnpB-RuapQAyYAub1t7oSdHH_pTD=f5k-s327ZvqMA@mail.gmail.com>
 <CAFqt6zY+07JBxAVfMqb+X78mXwFOj2VBh0nbR2tGnQOP9RrNkQ@mail.gmail.com>
 <20190729133642.GQ1250@mail-itl> <CAFqt6zZN+6r6wYJY+f15JAjj8dY+o30w_+EWH9Vy2kUXCKSBog@mail.gmail.com>
 <bf02becc-9db0-bb78-8efc-9e25cc115237@oracle.com> <20190730142233.GR1250@mail-itl>
In-Reply-To: <20190730142233.GR1250@mail-itl>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 30 Jul 2019 20:22:02 +0530
Message-ID: <CAFqt6zZOymx8RH75F69exukLYcGd45xpUHkRHK8nYXpwF8co6g@mail.gmail.com>
Subject: Re: [Xen-devel] [PATCH v4 8/9] xen/gntdev.c: Convert to use vm_map_pages()
To: =?UTF-8?Q?Marek_Marczykowski=2DG=C3=B3recki?= <marmarek@invisiblethingslab.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Juergen Gross <jgross@suse.com>, 
	Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, 
	xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>, stable@vger.kernel.org, 
	Greg KH <gregkh@linuxfoundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 7:52 PM Marek Marczykowski-G=C3=B3recki
<marmarek@invisiblethingslab.com> wrote:
>
> On Tue, Jul 30, 2019 at 10:05:42AM -0400, Boris Ostrovsky wrote:
> > On 7/30/19 2:03 AM, Souptick Joarder wrote:
> > > On Mon, Jul 29, 2019 at 7:06 PM Marek Marczykowski-G=C3=B3recki
> > > <marmarek@invisiblethingslab.com> wrote:
> > >> On Mon, Jul 29, 2019 at 02:02:54PM +0530, Souptick Joarder wrote:
> > >>> On Mon, Jul 29, 2019 at 1:35 PM Souptick Joarder <jrdr.linux@gmail.=
com> wrote:
> > >>>> On Sun, Jul 28, 2019 at 11:36 PM Marek Marczykowski-G=C3=B3recki
> > >>>> <marmarek@invisiblethingslab.com> wrote:
> > >>>>> On Fri, Feb 15, 2019 at 08:18:31AM +0530, Souptick Joarder wrote:
> > >>>>>> Convert to use vm_map_pages() to map range of kernel
> > >>>>>> memory to user vma.
> > >>>>>>
> > >>>>>> map->count is passed to vm_map_pages() and internal API
> > >>>>>> verify map->count against count ( count =3D vma_pages(vma))
> > >>>>>> for page array boundary overrun condition.
> > >>>>> This commit breaks gntdev driver. If vma->vm_pgoff > 0, vm_map_pa=
ges
> > >>>>> will:
> > >>>>>  - use map->pages starting at vma->vm_pgoff instead of 0
> > >>>> The actual code ignores vma->vm_pgoff > 0 scenario and mapped
> > >>>> the entire map->pages[i]. Why the entire map->pages[i] needs to be=
 mapped
> > >>>> if vma->vm_pgoff > 0 (in original code) ?
> > >> vma->vm_pgoff is used as index passed to gntdev_find_map_index. It's
> > >> basically (ab)using this parameter for "which grant reference to map=
".
> > >>
> > >>>> are you referring to set vma->vm_pgoff =3D 0 irrespective of value=
 passed
> > >>>> from user space ? If yes, using vm_map_pages_zero() is an alternat=
e
> > >>>> option.
> > >> Yes, that should work.
> > > I prefer to use vm_map_pages_zero() to resolve both the issues. Alter=
natively
> > > the patch can be reverted as you suggested. Let me know you opinion a=
nd wait
> > > for feedback from others.
> > >
> > > Boris, would you like to give any feedback ?
> >
> > vm_map_pages_zero() looks good to me. Marek, does it work for you?
>
> Yes, replacing vm_map_pages() with vm_map_pages_zero() fixes the
> problem for me.

Marek, I can send a patch for the same if you are ok.
We need to cc stable as this changes are available in 5.2.4.

>
> --
> Best Regards,
> Marek Marczykowski-G=C3=B3recki
> Invisible Things Lab
> A: Because it messes up the order in which people normally read text.
> Q: Why is top-posting such a bad thing?

