Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E098C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 23:45:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33BED21019
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 23:45:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33BED21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C635C8E0011; Wed, 13 Mar 2019 19:45:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C12998E0001; Wed, 13 Mar 2019 19:45:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B01108E0011; Wed, 13 Mar 2019 19:45:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 840B78E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 19:45:07 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id e1so3574275qth.23
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 16:45:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=osJb3SUZ5+M94ScAYgSArC48QvxH2p5EaPPbHtNHrkk=;
        b=MqHX7tcix+4iG4gwsFxyN62tq0MazJSSbTV2fDC0OTc1MAtbTJoFV9Ebh8Yw2CHfeq
         NvvdKOrbC9IG5JKw6OpBQAanuHMJI2X+ujbunWJmUBlfa0TzA9So+6JXAQVBKgTbyrUa
         d9JnyQpDrQsmcYpCGQFhqcbSxVlr5BfgNObF/tMrKNCXHOFZX8uqG5ysjMqBTUBJ9YSV
         j//cDG7qjxuZ5ofKSQ4vm3y1ojKkweh9z9MTjtCi1QCf+nMyKk1IzMHMh2yx+71VF2Uz
         /UFUN4TrBTtS79zoz50dpWTdg0G1wGkaNnibYA1ULF8LVIMrXOKDWwwUj0oC+HIQbCFH
         Usew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUdNg6Fpj47vAZmvZIyhlov7c86ISKZCBHrb65NR3uHzGnmd/6X
	JuimNxgxbYJ+K5cBHg4JHVvCofk1DcMyTJyhNksvYQX4d58+kIuooWnw4WZ5KRC3+L4WR/AuQNp
	CakIhk2rMUMnGRqB69du+NElnn/cluV1rxuaZw825W4BNv8k/cxlooxU+rx1LOUX7Wg==
X-Received: by 2002:a37:dd83:: with SMTP id u3mr12775149qku.98.1552520707182;
        Wed, 13 Mar 2019 16:45:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7MMYAB9dWvCpUKNkPxFI4LcA3d/zJYmc/XE4pYT5jw7hbnYPtOoVPSBXLIsM5pactUmfR
X-Received: by 2002:a37:dd83:: with SMTP id u3mr12775117qku.98.1552520706290;
        Wed, 13 Mar 2019 16:45:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552520706; cv=none;
        d=google.com; s=arc-20160816;
        b=H8q4zI0fPNslXdWEQcf/NWi9Ukm0KVKbmqd1OT5tH4D4h/0eq+rszPRaQCBB0ud7Bb
         nKI9Q3hOhxK4BezYQDMQuicerq2dFigaU2+MYaWzIwVLsY9IEw/VLQ/MnSZw3LuRQUrT
         PToBHiy5Jn190dCVjFHVQxCmhdKsBrSSNXNVQYePzcW/60odHtQGTYMJHnTi1Dubykzc
         9/mFYRzd+8mED+8dOvBRsTFVf//oMVFAfko7LAWd8L1MvSWBljVtOxZpXyIEFBz/a7i5
         5sx3V+fC8DML1vNapR7sejWhFpTUNVsTbca7bmgBi+Cig7GxDq/Uv6q+t8pZjgZbN71F
         btQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=osJb3SUZ5+M94ScAYgSArC48QvxH2p5EaPPbHtNHrkk=;
        b=rCWOOPiA2oAfsqD2lum2ho/zHfXM9N24QwkDnuTgPmPWxl8fON4vjl2TsaD3R3oJqA
         BLhAaORRDam8MHoHt9OpckgKPvvl/wlYdn39QBHJZN8No2wRbiXJhZ5RM6jLNKw2ieoz
         pwSAcBF5EEv0rX24sNfAV4x4/4Wzjdi1aE3plXOiLcHU9DGPbrfoLeXrpw7DhlGUMmD3
         x7UHjYuCrAUbvuQu/qQgFxJIRNYcqRIqGhO8zd+n5yPsz4FDleQ6AXhr6cbcNe/77seQ
         YXNBXgtxdEwU6Idnr4mx3ooKZLorUrd0/mbusZSoMyPG45zD9jFM/eexIZ4+WVrx/61w
         xCDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q38si2985199qtq.172.2019.03.13.16.45.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 16:45:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7FBDC12ADD;
	Wed, 13 Mar 2019 23:45:04 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D4C3317CE2;
	Wed, 13 Mar 2019 23:44:58 +0000 (UTC)
Date: Wed, 13 Mar 2019 19:44:58 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Peter Xu <peterx@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Maxime Coquelin <maxime.coquelin@redhat.com>, kvm@vger.kernel.org,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
	Marty McFadden <mcfadden8@llnl.gov>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-fsdevel@vger.kernel.org,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] userfaultfd: allow to forbid unprivileged users
Message-ID: <20190313234458.GJ25147@redhat.com>
References: <20190311093701.15734-1-peterx@redhat.com>
 <58e63635-fc1b-cb53-a4d1-237e6b8b7236@oracle.com>
 <20190313060023.GD2433@xz-x1>
 <3714d120-64e3-702e-6eef-4ef253bdb66d@redhat.com>
 <20190313185230.GH25147@redhat.com>
 <1934896481.7779933.1552504348591.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1934896481.7779933.1552504348591.JavaMail.zimbra@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 13 Mar 2019 23:45:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Paolo,

On Wed, Mar 13, 2019 at 03:12:28PM -0400, Paolo Bonzini wrote:
> 
> > On Wed, Mar 13, 2019 at 09:22:31AM +0100, Paolo Bonzini wrote:
> > Unless somebody suggests a consistent way to make hugetlbfs "just
> > work" (like we could achieve clean with CRIU and KVM), I think Oracle
> > will need a one liner change in the Oracle setup to echo into that
> > file in addition of running the hugetlbfs mount.
> 
> Hi Andrea, can you explain more in detail the risks of enabling
> userfaultfd for unprivileged users?

There's no more risk than in allowing mremap (direct memory overwrite
after underflow) or O_DIRECT (dirtycow) for unprivileged users.

If there was risk in allowing userfaultfd for unprivileged users,
CAP_SYS_PTRACE would be mandatory and there wouldn't be an option to
allow userfaultfd to all unprivileged users.

This is just an hardening policy in kernel (for those that don't run
everything under seccomp) that may even be removed later.

Unlike mremap and O_DIRECT, because we've only an handful of
(important) applications using userfaultfd so far, we can do like the
bpf syscall:

SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
{
	union bpf_attr attr = {};
	int err;

	if (sysctl_unprivileged_bpf_disabled && !capable(CAP_SYS_ADMIN))
		return -EPERM;

Except we picked CAP_SYS_PTRACE because CRIU already has to run with
such capability for other reasons.

So this is intended as the "sysctl_unprivileged_bpf_disabled" trick
applied to the bpf syscall, also applied to the userfaultfd syscall,
nothing more nothing less.

Then I thought we can add a tristate so an open of /dev/kvm would also
allow the syscall to make things more user friendly because
unprivileged containers ideally should have writable mounts done with
nodev and no matter the privilege they shouldn't ever get an hold on
the KVM driver (and those who do, like kubevirt, will then just work).

There has been one complaint because userfaultfd can also be used to
facilitate exploiting use after free bugs in other kernel code:

https://cyseclabs.com/blog/linux-kernel-heap-spray

This isn't a bug in userfaultfd, the only bug there is some kernel
code doing an use after free in a reproducible place, userfaultfd only
allows to stop copy-user where the exploits like copy-user to be
stopped.

This isn't particularly concerning, because you can achieve the same
objective with FUSE. In fact even if you set CONFIG_USERFAULTFD=n in
the kernel config and CONFIG_FUSE_FS=n, a security bug like that can
still be exploited eventually. It's just less reproducible if you
can't stop copy-user.

Restricting userfaultfd to privileged processes, won't make such
kernel bug become harmless, it'll just require more attempts to
exploit as far as I can tell. To put things in prospective, the
exploits for the most serious security bugs like mremap missing
underflow check, dirtycow or the missing stack_guard_gap would not
get any facilitation by userfaultfd.

I also thought we were randomizing all slab heaps by now to avoid
issues like above, I don't know if the randomized slab freelist oreder
CONFIG_SLAB_FREELIST_RANDOM and also the pointer with
CONFIG_SLAB_FREELIST_HARDENED precisely to avoid the exploits like
above. It's not like you can disable those two options even if you set
CONFIG_USERFAULTFD=n. I wonder if in that blog post the exploit was
set on a kernel with those two options enabled.

In any case not allowing non privileged processes to run the
userfaultfd syscall will provide some hardening feature also against
such kind of concern.

Thanks,
Andrea

