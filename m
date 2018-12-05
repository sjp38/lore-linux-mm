Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D29756B718C
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 19:42:57 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id ay11so13749927plb.20
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 16:42:57 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id r34si16049718pga.242.2018.12.04.16.42.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 16:42:56 -0800 (PST)
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: RFC: revisiting shared page tables
References: <20181204231623.GA19227@ubuette>
Date: Tue, 04 Dec 2018 16:42:55 -0800
In-Reply-To: <20181204231623.GA19227@ubuette> (Larry Bassel's message of "Tue,
	4 Dec 2018 15:16:24 -0800")
Message-ID: <87y3947qi8.fsf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Bassel <larry.bassel@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Larry Bassel <larry.bassel@oracle.com> writes:
>
> Isn't Linux kernel archaeology fun :-)
>
> 13 years have elapsed. Given the many changes in the kernel since the original
> patch submission, I'd appreciate your insight into the following questions:

I believe the main objection (from Linus) back then that it would
complicate page table locking significantly, and also add overhead for
it. If anything locking (or even lack of locking, as in lockless code)
has gotten far more hairy in the 13 years, so this issue likely got
far worse.

So if you would work on it I would start with some investigation
what the locking scheme would take, how maintainable it would be,
and how many atomics in hot paths it would add.

-Andi
