Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 809A46B2C43
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 11:53:52 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id y85so9421513wmc.7
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 08:53:52 -0800 (PST)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id v132si3795226wmg.113.2018.11.22.08.53.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 08:53:51 -0800 (PST)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20181122165106.18238-2-daniel.vetter@ffwll.ch>
References: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
 <20181122165106.18238-2-daniel.vetter@ffwll.ch>
Message-ID: <154290561362.11623.15299444358726283678@skylake-alporthouse-com>
Subject: Re: [Intel-gfx] [PATCH 1/3] mm: Check if mmu notifier callbacks are allowed
 to fail
Date: Thu, 22 Nov 2018 16:53:34 +0000
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>, LKML <linux-kernel@vger.kernel.org>
Cc: Michal Hocko <mhocko@suse.com>, Daniel Vetter <daniel.vetter@intel.com>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>, =?utf-8?b?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, David Rientjes <rientjes@google.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, =?utf-8?q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>

Quoting Daniel Vetter (2018-11-22 16:51:04)
> Just a bit of paranoia, since if we start pushing this deep into
> callchains it's hard to spot all places where an mmu notifier
> implementation might fail when it's not allowed to.

Most callers could handle the failure correctly. It looks like the
failure was not propagated for convenience.
-Chris
