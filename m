Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8616B6EB3
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 07:30:23 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id i14so8055643edf.17
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 04:30:23 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 04 Dec 2018 13:30:20 +0100
From: osalvador@suse.de
Subject: Re: [RFC PATCH] hwpoison, memory_hotplug: allow hwpoisoned pages to
 be offlined
In-Reply-To: <20181203100309.14784-1-mhocko@kernel.org>
References: <20181203100309.14784-1-mhocko@kernel.org>
Message-ID: <18f10c47fe10b89ad61c29bf3c7801ca@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Oscar Salvador <OSalvador@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@gmail.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Stable tree <stable@vger.kernel.org>, owner-linux-mm@kvack.org

On 2018-12-03 11:03, Michal Hocko wrote:
> Debugged-by: Oscar Salvador <osalvador@suse.com>
> Cc: stable
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Bit by bit memory-hotplug is getting trained :-)

Reviewed-by: Oscar Salvador <osalvador@suse.com>
