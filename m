Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id C4F476B0035
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 07:35:13 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id r5so1797830qcx.26
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 04:35:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z9si5803678qcn.9.2014.09.17.04.35.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Sep 2014 04:35:12 -0700 (PDT)
Date: Wed, 17 Sep 2014 13:35:00 +0200
From: Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>
Subject: Re: [PATCH] kvm: Faults which trigger IO release the mmap_sem
Message-ID: <20140917113458.GA1462@potion.brq.redhat.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
 <54184078.4070505@redhat.com>
 <20140916205110.GA1273@potion.brq.redhat.com>
 <CAJu=L59f6ODMDOiKEGGSGg+0RhYw3FDy5D7AJcCOrHD5xL_iwQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAJu=L59f6ODMDOiKEGGSGg+0RhYw3FDy5D7AJcCOrHD5xL_iwQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

[Repost for lists, the last mail was eaten by a security troll.]

2014-09-16 14:01-0700, Andres Lagar-Cavilla:
> On Tue, Sep 16, 2014 at 1:51 PM, Radim KrA?mA!A? <rkrcmar@redhat.com>
> wrote:
> > 2014-09-15 13:11-0700, Andres Lagar-Cavilla:
> >> +int kvm_get_user_page_retry(struct task_struct *tsk, struct
> >> mm_struct *mm,
> >
> > The suffix '_retry' is not best suited for this.
> > On first reading, I imagined we will be retrying something from
> > before,
> > possibly calling it in a loop, but we are actually doing the first
> > and
> > last try in one call.
>
> We are doing ... the second and third in most scenarios. async_pf did
> the first with _NOWAIT. We call this from the async pf retrier, or if
> async pf couldn't be notified to the guest.

I was thinking more about what the function does, not how we currently
use it -- nothing prevents us from using it as first somewhere -- but
yeah, even comments would be off then.

> >> Apart from this, the patch looks good.  The mm/ parts are minimal,
> >> so
> >> I
> >> think it's best to merge it through the KVM tree with someone's
> >> Acked-by.
> >
> > I would prefer to have the last hunk in a separate patch, but still,
> >
> > Acked-by: Radim KrA?mA!A? <rkrcmar@redhat.com>
>
> Awesome, thanks much.
>
> I'll recut with the VM_BUG_ON from Paolo and your Ack. LMK if anything
> else from this email should go into the recut.

Ah, sorry, I'm not maintaining mm ... what I meant was

Reviewed-by: Radim KrA?mA!A? <rkrcmar@redhat.com>

and I had to leave before I could find a good apology for
VM_WARN_ON_ONCE(), so if you are replacing BUG_ON, you might want to
look at that one as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
