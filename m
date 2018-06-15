Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 18C9A6B000C
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 10:38:34 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id m4-v6so7642284qtn.19
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 07:38:34 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c45-v6si913075qte.201.2018.06.15.07.38.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 07:38:33 -0700 (PDT)
Date: Fri, 15 Jun 2018 17:38:31 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v33 0/4] Virtio-balloon: support free page reporting
Message-ID: <20180615172933-mutt-send-email-mst@kernel.org>
References: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com>
 <20180615142610-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F7396A3DC9@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <286AC319A985734F985F78AFA26841F7396A3DC9@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Wei W" <wei.w.wang@intel.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "peterx@redhat.com" <peterx@redhat.com>

On Fri, Jun 15, 2018 at 02:28:49PM +0000, Wang, Wei W wrote:
> On Friday, June 15, 2018 7:30 PM, Michael S. Tsirkin wrote:
> > On Fri, Jun 15, 2018 at 12:43:09PM +0800, Wei Wang wrote:
> > >       - remove the cmd id related interface. Now host can just send a free
> > >         page hint command to the guest (via the host_cmd config register)
> > >         to start the reporting.
> > 
> > Here we go again. And what if reporting was already started previously?
> > I don't think it's a good idea to tweak the host/guest interface yet again.
> 
> This interface is much simpler, and I'm not sure if that would be an
> issue here now, because now the guest delivers the whole buffer of
> hints to host once, instead of hint by hint as before. And the guest
> notifies host after the buffer is delivered. In any case, the host
> doorbell handler will be invoked, if host doesn't need the hints at
> that time, it will just give back the buffer. There will be no stale
> hints remained in the ring now.
> 
> Best,
> Wei

I still think all the old arguments for cmd id apply.

-- 
MST
