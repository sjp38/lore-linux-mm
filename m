Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 4CEDE6B00B0
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 10:47:36 -0500 (EST)
Date: Wed, 21 Nov 2012 16:47:34 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [memcg:since-3.6 456/496]
 drivers/virtio/virtio_balloon.c:145:10: warning: format '%zu' expects
 argument of type 'size_t', but argument 4 has type 'unsigned int'
Message-ID: <20121121154734.GE8761@dhcp22.suse.cz>
References: <50acf531.zaJ8wmQW+6NHVbhr%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50acf531.zaJ8wmQW+6NHVbhr%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Bahh, my fault.
I screwed while reverting previous version of the virtio patchset.
Pushed to my tree. Thanks for reporting...

On Wed 21-11-12 23:37:21, Wu Fengguang wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.6
> head:   223cdc1faeea55aa70fef23d54720ad3fdaf4c93
> commit: 12cf48af8968fa1d0cc4c06065d7c37c3560c171 [456/496] virtio_balloon: introduce migration primitives to balloon pages
> config: make ARCH=x86_64 allmodconfig
---
