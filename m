Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0E0E56B0009
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 19:25:41 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id i23so9523137qke.1
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 16:25:41 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id i28si682841qta.77.2018.04.10.16.25.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 16:25:39 -0700 (PDT)
Date: Wed, 11 Apr 2018 02:25:33 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v29 1/4] mm: support reporting free page blocks
Message-ID: <20180411022440-mutt-send-email-mst@kernel.org>
References: <1522031994-7246-1-git-send-email-wei.w.wang@intel.com>
 <1522031994-7246-2-git-send-email-wei.w.wang@intel.com>
 <20180326142254.c4129c3a54ade686ee2a5e21@linux-foundation.org>
 <20180410211719-mutt-send-email-mst@kernel.org>
 <20180410135429.d1aeeb91d7f2754ffe7fb80e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410135429.d1aeeb91d7f2754ffe7fb80e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, huangzhichao@huawei.com

On Tue, Apr 10, 2018 at 01:54:29PM -0700, Andrew Morton wrote:
> On Tue, 10 Apr 2018 21:19:31 +0300 "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > 
> > Andrew, were your questions answered? If yes could I bother you for an ack on this?
> > 
> 
> Still not very happy that readers are told that "this function may
> sleep" when it clearly doesn't do so.  If we wish to be able to change
> it to sleep in the future then that should be mentioned.  And even put a
> might_sleep() in there, to catch people who didn't read the comments...
> 
> Otherwise it looks OK.

Oh, might_sleep with a comment explaining it's for the future sounds
good to me. I queued this - Wei, could you post a patch on top pls?

-- 
MST
