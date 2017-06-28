Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 115986B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 04:54:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id n124so9101775wmg.5
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 01:54:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c46si1402564wra.29.2017.06.28.01.54.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 01:54:12 -0700 (PDT)
Date: Wed, 28 Jun 2017 10:54:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 22/23] usercopy: split user-controlled slabs to separate
 caches
Message-ID: <20170628085408.GB5225@dhcp22.suse.cz>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
 <1497915397-93805-23-git-send-email-keescook@chromium.org>
 <06bde73d-ca3c-8f91-0142-ddf3af99875e@redhat.com>
 <CAGXu5jKBB8TF7e74QkuxOu0iy6TZe3Q_0Fs21tbyq23Js3v3Mw@mail.gmail.com>
 <20170627073132.GC28078@dhcp22.suse.cz>
 <CAGXu5jK5L8ZhMAHEMBDWhnDMDS-Wt-aNMUbOMrMHT25qWqNoRA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jK5L8ZhMAHEMBDWhnDMDS-Wt-aNMUbOMrMHT25qWqNoRA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <labbott@redhat.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, David Windsor <dave@nullcore.net>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 27-06-17 15:07:17, Kees Cook wrote:
> On Tue, Jun 27, 2017 at 12:31 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > But I am not really sure I understand consequences of this patch. So how
> > do those attacks look like. Do you have an example of a CVE which would
> > be prevented by this measure?
> 
> It's a regular practice, especially for heap grooming. You can see an
> example here:
> http://cyseclabs.com/blog/cve-2016-6187-heap-off-by-one-exploit
> which even recognizes this as a common method, saying "the standard
> msgget() technique". Having the separate caches doesn't strictly
> _stop_ some attacks, but it changes the nature of what the attacker
> has to do. Instead of having a universal way to groom the heap, they
> must be forced into other paths. Generally speaking this can reduce
> what's possible making the attack either impossible, more expensive to
> develop, or less reliable.

Thanks that makes it more clear to me. I believe this would be a useful
information in the changelog.

> >> This would mean building out *_user() versions for all the various
> >> *alloc() functions, though. That gets kind of long/ugly.
> >
> > Only prepare those which are really needed. It seems only handful of
> > them in your patch.
> 
> Okay, if that's the desired approach, we can do that.

yes please
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
