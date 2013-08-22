Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 2D73B6B0032
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 20:35:11 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id j6so2337376oag.28
        for <linux-mm@kvack.org>; Wed, 21 Aug 2013 17:35:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130821204901.GA19802@redhat.com>
References: <20130807055157.GA32278@redhat.com>
	<CAJd=RBCJv7=Qj6dPW2Ha=nq6JctnK3r7wYCAZTm=REVOZUNowg@mail.gmail.com>
	<20130807153030.GA25515@redhat.com>
	<CAJd=RBCyZU8PR7mbFUdKsWq3OH+5HccEWKMEH5u7GNHNy3esWg@mail.gmail.com>
	<20130819231836.GD14369@redhat.com>
	<CAJd=RBA-UZmSTxNX63Vni+UPZBHwP4tvzE_qp1ZaHBqcNG7Fcw@mail.gmail.com>
	<20130821204901.GA19802@redhat.com>
Date: Thu, 22 Aug 2013 08:35:10 +0800
Message-ID: <CAJd=RBC8ABbTwt476RcfhALqWdY+H8eva6bpDhYqv=Ggo9hXBg@mail.gmail.com>
Subject: Re: unused swap offset / bad page map.
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Hillf Danton <dhillf@gmail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, Aug 22, 2013 at 4:49 AM, Dave Jones <davej@redhat.com> wrote:
>
> didn't hit the bug_on, but got a bunch of
>
> [  424.077993] swap_free: Unused swap offset entry 000187d5
> [  439.377194] swap_free: Unused swap offset entry 000187e7
> [  441.998411] swap_free: Unused swap offset entry 000187ee
> [  446.956551] swap_free: Unused swap offset entry 0000245f
>
Related to the regression reported?

Regression: x86/mm: new _PTE_SWP_SOFT_DIRTY bit conflicts with existing use
https://lkml.org/lkml/2013/8/21/294

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
