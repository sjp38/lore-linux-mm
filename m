Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id EABD36B0006
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 03:24:36 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id t17-v6so7157469wrv.13
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 00:24:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l4-v6sor221781wru.48.2018.10.12.00.24.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Oct 2018 00:24:35 -0700 (PDT)
Subject: Re: [PATCH] mm: Speed up mremap on large regions
References: <20181009201400.168705-1-joel@joelfernandes.org>
 <CAG48ez3yLkMcyaTXFt_+w8_-HtmrjW=XB51DDQSGdjPj43XWmA@mail.gmail.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <927d98c0-ec81-ce7a-994d-6405abce18db@redhat.com>
Date: Fri, 12 Oct 2018 09:24:32 +0200
MIME-Version: 1.0
In-Reply-To: <CAG48ez3yLkMcyaTXFt_+w8_-HtmrjW=XB51DDQSGdjPj43XWmA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>, joel@joelfernandes.org
Cc: kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel-team@android.com, Minchan Kim <minchan@google.com>, Hugh Dickins <hughd@google.com>, lokeshgidra@google.com, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, pombredanne@nexb.com, Thomas Gleixner <tglx@linutronix.de>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, kvm@vger.kernel.org

On 12/10/2018 05:21, Jann Horn wrote:
> I don't know how this interacts with shadow paging implementations.

Shadow paging simply uses MMU notifiers and that does not assume that
PTE invalidation is atomic.  The invalidate_range_start and
invalidate_range_end calls are not affected by Joel's patch, so it's ok
for KVM and also for other users of MMU notifiers.

Paolo
