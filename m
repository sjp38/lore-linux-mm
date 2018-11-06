Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7BDE96B0381
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 12:32:14 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id s24-v6so13758320plp.12
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 09:32:14 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 31si6735324pgl.595.2018.11.06.09.32.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 09:32:13 -0800 (PST)
Subject: Re: [PATCH v7] mm, drm/i915: mark pinned shmemfs pages as unevictable
References: <20181106093100.71829-1-vovoy@chromium.org>
 <20181106132324.17390-1-chris@chris-wilson.co.uk>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <14fd3be8-5415-a6e1-c45f-4b229dee9f93@intel.com>
Date: Tue, 6 Nov 2018 09:32:12 -0800
MIME-Version: 1.0
In-Reply-To: <20181106132324.17390-1-chris@chris-wilson.co.uk>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kuo-Hsin Yang <vovoy@chromium.org>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

On 11/6/18 5:23 AM, Chris Wilson wrote:
> + (3) By the i915 driver to mark pinned address space until it's unpinned. The
> +     amount of unevictable memory marked by i915 driver is roughly the bounded
> +     object size in debugfs/dri/0/i915_gem_objects.

Thanks for adding this.  Feel free to add my:

Acked-by: Dave Hansen <dave.hansen@intel.com>
