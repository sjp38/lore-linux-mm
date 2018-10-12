Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4BD816B000A
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 17:12:07 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 43-v6so10525961ple.19
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 14:12:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q19-v6si2350843pll.286.2018.10.12.14.12.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 14:12:06 -0700 (PDT)
Date: Fri, 12 Oct 2018 14:12:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/7] HMM updates, improvements and fixes
Message-Id: <20181012141203.40a0c5272821e43e97382894@linux-foundation.org>
In-Reply-To: <20181012181545.GG6593@redhat.com>
References: <20180824192549.30844-1-jglisse@redhat.com>
	<20181012181545.GG6593@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 12 Oct 2018 14:15:45 -0400 Jerome Glisse <jglisse@redhat.com> wrote:

> On Fri, Aug 24, 2018 at 03:25:42PM -0400, jglisse@redhat.com wrote:
> > From: J=E9r=F4me Glisse <jglisse@redhat.com>
> >=20
> > Few fixes that only affect HMM users. Improve the synchronization call
> > back so that we match was other mmu_notifier listener do and add proper
> > support to the new blockable flags in the process.
> >=20
> > For curious folks here are branches to leverage HMM in various existing
> > device drivers:
> >=20
> > https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dhmm-nouveau-v01
> > https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dhmm-radeon-v00
> > https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dhmm-intel-v00
> >=20
> > More to come (amd gpu, Mellanox, ...)
> >=20
> > I expect more of the preparatory work for nouveau will be merge in 4.20
> > (like we have been doing since 4.16) and i will wait until this patchset
> > is upstream before pushing the patches that actualy make use of HMM (to
> > avoid complex tree inter-dependency).
> >=20
>=20
> Andrew do you want me to repost this on top of lastest mmotm ?
> All conflict should be pretty trivial to fix.

Please.  I ducked v1 because a v2 was in the works.  It's very late in
the cycle so you might want to prepare an urgent-for-4.19 series and a
for-4.20 series.  Or, better, a single series with the appropriate
Cc:stable tags.

Please ensure that all review questions which have thus far been
received are appropriately answered in code comments and in changelogs.
Because if one reader was wondering about something, others will
wonder the same thing in the future.
