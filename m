Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id A2E396B0074
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 09:47:25 -0500 (EST)
Date: Thu, 29 Nov 2012 15:47:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [memcg:since-3.6 480/499] mm/highmem.c:157:8: error: void value
 not ignored as it ought to be
Message-ID: <20121129144722.GD27887@dhcp22.suse.cz>
References: <50b76ffc.m4U/dAKBPFmQn+3W%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50b76ffc.m4U/dAKBPFmQn+3W%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org

On Thu 29-11-12 22:23:56, Wu Fengguang wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.6
> head:   8695b9105cdb22a5a4b66eea52c0232cbd5e6e48
> commit: b86ed88f692e53331ef7d6b6b753993df75fc59a [480/499] Reverted "mm, highmem: makes flush_all_zero_pkmaps() return index of last flushed entry"
> config: i386-randconfig-b780 (attached as .config)
> 
> All error/warnings:
> 
> mm/highmem.c: In function 'kmap_flush_unused':
> mm/highmem.c:157:8: error: void value not ignored as it ought to be
> mm/highmem.c:158:15: error: 'PKMAP_INVALID_INDEX' undeclared (first use in this function)
> mm/highmem.c:158:15: note: each undeclared identifier is reported only once for each function it appears in

Dohh, I have screwed revert of "mm, highmem: makes
flush_all_zero_pkmaps() return index of last flushed entry"

Thanks a lot for the report

The patch bellow should heal this.
---
