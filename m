Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 950076B026E
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:44:17 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id y7-v6so5904603plh.7
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:44:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m18si3935620pgu.352.2018.04.13.06.44.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 06:44:16 -0700 (PDT)
Date: Fri, 13 Apr 2018 15:44:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 0/8] mm: online/offline 4MB chunks controlled by
 device driver
Message-ID: <20180413134414.GS17484@dhcp22.suse.cz>
References: <20180413131632.1413-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180413131632.1413-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org

[If you choose to not CC the same set of people on all patches - which
is sometimes a legit thing to do - then please cc them to the cover
letter at least.]

On Fri 13-04-18 15:16:24, David Hildenbrand wrote:
> I am right now working on a paravirtualized memory device ("virtio-mem").
> These devices control a memory region and the amount of memory available
> via it. Memory will not be indicated via ACPI and friends, the device
> driver is responsible for it.

How does this compare to other ballooning solutions? And why your driver
cannot simply use the existing sections and maintain subsections on top?
-- 
Michal Hocko
SUSE Labs
