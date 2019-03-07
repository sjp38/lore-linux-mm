Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D118C10F03
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 20:17:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0765620840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 20:17:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0765620840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 607CB8E0003; Thu,  7 Mar 2019 15:17:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B6668E0002; Thu,  7 Mar 2019 15:17:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A5C48E0003; Thu,  7 Mar 2019 15:17:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1DEE58E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 15:17:32 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id o2so14076036qkb.11
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 12:17:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=8DM85+gNfasZs1XYNsziHxgcxYrCLKTTZ2r77fzd7b0=;
        b=cr2OgzUYk4PM7ZzVEB8eZwuYdc8qy/jNpOFBBlmCCcSAOj5qRl4fdz45yN4dgbNlw4
         Cx+hVZJkbbFPUJT44jT6IboNzdK+t0482K6hC6goaxsmRDmdj56TkYAf6oChEwkZWm+q
         RfGDTad52PWHa5rYRYXv2fSXgf62DYBNzteErFVx6aF2pHU3G1rtKpD1UbPgroQ/McFT
         ZhyO0pkAz5sBkW7bpjzRHP5A0LiMpfHJyIbCcB1oYJ2t11wyoyVGEzgEk4DxOvVOoBbl
         VBPHo9LWhZLYh2CuJ3x/R4QIERIfuruPXgD0/q4XTXMtXMunM8JhqqKPO77Em4eISyes
         QRUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUGRvxI2e8x1XkUENIlGp/ikRWMCG0fV1cmTwQpRPxAke9N86mr
	en8nRyYaj4h/I5big8ewTlKdz/RQMuecMWseVhQsJBjMCHqaE491UhSaVmU5xaXNedQn2nN5FuV
	vbin4HCeHcgtrgJgg8y+1y4+q4wOaeNAaRLdTFv37lqZzE0edwNyhgOJWbKBhcUNzqg==
X-Received: by 2002:a0c:b64a:: with SMTP id q10mr11980950qvf.6.1551989851870;
        Thu, 07 Mar 2019 12:17:31 -0800 (PST)
X-Google-Smtp-Source: APXvYqwv12hGlljOyFDhRSl9TWCJpm68sJnGrDeQBjOkCfkFZMv3xjX7A6aF0rx9C1Lu9I4Otz3R
X-Received: by 2002:a0c:b64a:: with SMTP id q10mr11980895qvf.6.1551989850915;
        Thu, 07 Mar 2019 12:17:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551989850; cv=none;
        d=google.com; s=arc-20160816;
        b=OUjq9Dgaspk0pdxEDeWkqhKfC7kF0fJW1UjaTPLF8O8NevUHcuBOkat+/T/mST/O+o
         /HVGRaJc3IKpMoH5h/R0qrvhw+q3iP6UVUWfkhsbwY7WzRxNbR6WRKeKqA2bie28FUih
         NaoZ/M5ZhmMrkJoB0Y6ypqmFdzyupOr0hBvJRNiXpvSJ2vTGzeQlFl1o/AbxIAdmNOI+
         2SffKRt6R9t7bV32u5uBRRW644+1F2RsFSbneRMM+IKOK5Qr4MiYrxjp8YkNL0RrvTnT
         2k7t7FPo7gcqCwdlwOIVOqUlrU68icwPYT6w3hDIvROwCThkQ52ZEsyRZRNF7w7CaVk+
         73ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=8DM85+gNfasZs1XYNsziHxgcxYrCLKTTZ2r77fzd7b0=;
        b=i8B/6WH9DBLzFyv7JlYYaH3SAIgyTLVKp8dtBJXIayRs3Uc8OTpBeJ5NyveAnQEDs6
         OSLpuYiKIhtG8KoVZ3PggJ8pPYt5ExajtautWdjaWbEvFcQdsdKs87L3mL+g8MMyLEa/
         cQpKiShhQx0S0jOK7kL0l1b5YoshTmpiMcXa2ffDVnPcMUH9hzMEeUyJCjJ/+QL9y02y
         CTfM9s6SAgIXFcJJbXjNlCd3yPJCWYn7RK/jVO0/LZsgFN3/VbTTXnK+z1e+IXQ9kO72
         pCHe4uQrblnHqtShZPTh3EGXT4P5pT3b2ADjVlNRleVFSuSdzlZZq4ZhEnyMslK05ku2
         tW4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i68si1106423qtb.290.2019.03.07.12.17.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 12:17:30 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 09FAF307D97F;
	Thu,  7 Mar 2019 20:17:30 +0000 (UTC)
Received: from redhat.com (ovpn-125-54.rdu2.redhat.com [10.10.125.54])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 9ED571001DD8;
	Thu,  7 Mar 2019 20:17:24 +0000 (UTC)
Date: Thu, 7 Mar 2019 15:17:22 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peterx@redhat.com, linux-mm@kvack.org, Jan Kara <jack@suse.cz>
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190307201722.GG3835@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190306092837-mutt-send-email-mst@kernel.org>
 <15105894-4ec1-1ed0-1976-7b68ed9eeeda@redhat.com>
 <20190307101708-mutt-send-email-mst@kernel.org>
 <20190307190910.GE3835@redhat.com>
 <20190307193838.GQ23850@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190307193838.GQ23850@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Thu, 07 Mar 2019 20:17:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 02:38:38PM -0500, Andrea Arcangeli wrote:
> On Thu, Mar 07, 2019 at 02:09:10PM -0500, Jerome Glisse wrote:
> > I thought this patch was only for anonymous memory ie not file back ?
> 
> Yes, the other common usages are on hugetlbfs/tmpfs that also don't
> need to implement writeback and are obviously safe too.
> 
> > If so then set dirty is mostly useless it would only be use for swap
> > but for this you can use an unlock version to set the page dirty.
> 
> It's not a practical issue but a security issue perhaps: you can
> change the KVM userland to run on VM_SHARED ext4 as guest physical
> memory, you could do that with the qemu command line that is used to
> place it on tmpfs or hugetlbfs for example and some proprietary KVM
> userland may do for other reasons. In general it shouldn't be possible
> to crash the kernel with this, and it wouldn't be nice to fail if
> somebody decides to put VM_SHARED ext4 (we could easily allow vhost
> ring only backed by anon or tmpfs or hugetlbfs to solve this of
> course).
> 
> It sounds like we should at least optimize away the _lock from
> set_page_dirty if it's anon/hugetlbfs/tmpfs, would be nice if there
> was a clean way to do that.
> 
> Now assuming we don't nak the use on ext4 VM_SHARED and we stick to
> set_page_dirty_lock for such case: could you recap how that
> __writepage ext4 crash was solved if try_to_free_buffers() run on a
> pinned GUP page (in our vhost case try_to_unmap would have gotten rid
> of the pins through the mmu notifier and the page would have been
> freed just fine).

So for the above the easiest thing is to call set_page_dirty() from
the mmu notifier callback. It is always safe to use the non locking
variant from such callback. Well it is safe only if the page was
map with write permission prior to the callback so here i assume
nothing stupid is going on and that you only vmap page with write
if they have a CPU pte with write and if not then you force a write
page fault.

Basicly from mmu notifier callback you have the same right as zap
pte has.
> 

> The first two things that come to mind is that we can easily forbid
> the try_to_free_buffers() if the page might be pinned by GUP, it has
> false positives with the speculative pagecache lookups but it cannot
> give false negatives. We use those checks to know when a page is
> pinned by GUP, for example, where we cannot merge KSM pages with gup
> pins etc... However what if the elevated refcount wasn't there when
> try_to_free_buffers run and is there when __remove_mapping runs?
> 
> What I mean is that it sounds easy to forbid try_to_free_buffers for
> the long term pins, but that still won't prevent the same exact issue
> for a transient pin (except the window to trigger it will be much smaller).

I think here you do not want to go down the same path as what is being
plane for GUP. GUP is being fix for "broken" hardware. Myself i am
converting proper hardware to no longer use GUP but rely on mmu notifier.

So i would not do any dance with blocking try_to_free_buffer, just
do everything from mmu notifier callback and you are fine.

> 
> I basically don't see how long term GUP pins breaks stuff in ext4
> while transient short term GUP pins like O_DIRECT don't. The VM code
> isn't able to disambiguate if the pin is short or long term and it
> won't even be able to tell the difference between a GUP pin (long or
> short term) and a speculative get_page_unless_zero run by the
> pagecache speculative pagecache lookup. Even a random speculative
> pagecache lookup that runs just before __remove_mapping, can cause
> __remove_mapping to fail despite try_to_free_buffers() succeeded
> before it (like if there was a transient or long term GUP
> pin). speculative lookup that can happen across all page struct at all
> times and they will cause page_ref_freeze in __remove_mapping to
> fail.
> 
> I'm sure I'm missing details on the ext4 __writepage problem and how
> set_page_dirty_lock broke stuff with long term GUP pins, so I'm
> asking...

O_DIRECT can suffer from the same issue but the race window for that
is small enough that it is unlikely it ever happened. But for device
driver that GUP page for hours/days/weeks/months ... obviously the
race window is big enough here. It affects many fs (ext4, xfs, ...)
in different ways. I think ext4 is the most obvious because of the
kernel log trace it leaves behind.

Bottom line is for set_page_dirty to be safe you need the following:
    lock_page()
    page_mkwrite()
    set_pte_with_write()
    unlock_page()

Now when loosing the write permission on the pte you will first get
a mmu notifier callback so anyone that abide by mmu notifier is fine
as long as they only write to the page if they found a pte with
write as it means the above sequence did happen and page is write-
able until the mmu notifier callback happens.

When you lookup a page into the page cache you still need to call
page_mkwrite() before installing a write-able pte.

Here for this vmap thing all you need is that the original user
pte had the write flag. If you only allow write in the vmap when
the original pte had write and you abide by mmu notifier then it
is ok to call set_page_dirty from the mmu notifier (but not after).

Hence why my suggestion is a special vunmap that call set_page_dirty
on the page from the mmu notifier.

Cheers,
Jérôme

