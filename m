Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id AC4BA6B0006
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 04:52:36 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id k66so44060409qkf.1
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 01:52:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e17si498010qkj.109.2018.11.15.01.52.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 01:52:36 -0800 (PST)
Date: Thu, 15 Nov 2018 17:52:25 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181115095225.GO2653@MiWiFi-R3L-srv>
References: <20181114070909.GB2653@MiWiFi-R3L-srv>
 <5a6c6d6b-ebcd-8bfa-d6e0-4312bfe86586@redhat.com>
 <20181114090134.GG23419@dhcp22.suse.cz>
 <20181114145250.GE2653@MiWiFi-R3L-srv>
 <20181114150029.GY23419@dhcp22.suse.cz>
 <20181115051034.GK2653@MiWiFi-R3L-srv>
 <20181115073052.GA23831@dhcp22.suse.cz>
 <20181115075349.GL2653@MiWiFi-R3L-srv>
 <20181115083055.GD23831@dhcp22.suse.cz>
 <a1d4aa33-5c6d-1a6d-1426-46b2cebbf57e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a1d4aa33-5c6d-1a6d-1426-46b2cebbf57e@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com

On 11/15/18 at 10:42am, David Hildenbrand wrote:
> I am wondering why it is always the last memory block of that device
> (and even that node). Coincidence?

I remember one or two times it's the last 6G or 4G which stall there,
the size of memory block is 2G. But most of time it's the last memory
block. And from the debug printing added by Michal's patch, it's the
stress program itself which owns the migrating page and loop forvever
there.
