Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B114A6B2095
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 10:13:33 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id o9so1449602pgv.19
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 07:13:33 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y3-v6si42858511pfe.42.2018.11.20.07.13.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 07:13:31 -0800 (PST)
Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com [209.85.128.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 22F42208E4
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 15:13:31 +0000 (UTC)
Received: by mail-wm1-f51.google.com with SMTP id g131so2459745wmg.3
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 07:13:31 -0800 (PST)
MIME-Version: 1.0
References: <20181120052137.74317-1-joel@joelfernandes.org>
In-Reply-To: <20181120052137.74317-1-joel@joelfernandes.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 20 Nov 2018 07:13:17 -0800
Message-ID: <CALCETrXgBENat=5=7EuU-ttQ-YSXT+ifjLGc=hpJ=unRgSsndw@mail.gmail.com>
Subject: Re: [PATCH -next 1/2] mm/memfd: make F_SEAL_FUTURE_WRITE seal more robust
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Jann Horn <jannh@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, Linux API <linux-api@vger.kernel.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Shuah Khan <shuah@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Mon, Nov 19, 2018 at 9:21 PM Joel Fernandes (Google)
<joel@joelfernandes.org> wrote:
>
> A better way to do F_SEAL_FUTURE_WRITE seal was discussed [1] last week
> where we don't need to modify core VFS structures to get the same
> behavior of the seal. This solves several side-effects pointed out by
> Andy [2].
>
> [1] https://lore.kernel.org/lkml/20181111173650.GA256781@google.com/
> [2] https://lore.kernel.org/lkml/69CE06CC-E47C-4992-848A-66EB23EE6C74@amacapital.net/
>
> Suggested-by: Andy Lutomirski <luto@kernel.org>
> Fixes: 5e653c2923fd ("mm: Add an F_SEAL_FUTURE_WRITE seal to memfd")

What tree is that commit in?  Can we not just fold this in?
