Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7167B6B0031
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 18:19:15 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id ld10so4235980pab.20
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 15:19:15 -0800 (PST)
Received: from psmtp.com ([74.125.245.175])
        by mx.google.com with SMTP id ws5si3251588pab.35.2013.11.15.15.19.12
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 15:19:14 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CA+8MBbJR+AbGY41=TMOfJUd2u927ADa8O_-12sFUcNYnN34oMw@mail.gmail.com>
References: <1383833644-27091-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CA+8MBbL-WpcC6_wfZeFW6Buqq0p1PStH5ScF-USHae40H3MXfg@mail.gmail.com>
 <CA+8MBbJR+AbGY41=TMOfJUd2u927ADa8O_-12sFUcNYnN34oMw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: Properly separate the bloated ptl from the
 regular case
Content-Transfer-Encoding: 7bit
Message-Id: <20131115231548.60418E0090@blue.fi.intel.com>
Date: Sat, 16 Nov 2013 01:15:48 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Tony Luck wrote:
> On Fri, Nov 15, 2013 at 2:01 PM, Tony Luck <tony.luck@gmail.com> wrote:
> Help!

Could you try this:
