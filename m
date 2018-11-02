Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9BC8C6B0006
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 10:05:46 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id n5-v6so1767727plp.16
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 07:05:46 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id l12-v6si33114237pgj.76.2018.11.02.07.05.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 07:05:45 -0700 (PDT)
Subject: Re: [PATCH v3] mm, drm/i915: mark pinned shmemfs pages as unevictable
References: <20181031081945.207709-1-vovoy@chromium.org>
 <039b2768-39ff-6196-9615-1f0302ee3e0e@intel.com>
 <CAEHM+4q7V3d+EiHR6+TKoJC=6Ga0eCLWik0oJgDRQCpWps=wMA@mail.gmail.com>
 <80347465-38fd-54d3-facf-bcd6bf38228a@intel.com>
 <CAEHM+4rsV9G_cahOyyH8njOYyZc5C9b0a6CV4AH_Y7EubXBLAQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b114017f-edeb-2055-1313-0d7821d633ae@intel.com>
Date: Fri, 2 Nov 2018 07:05:44 -0700
MIME-Version: 1.0
In-Reply-To: <CAEHM+4rsV9G_cahOyyH8njOYyZc5C9b0a6CV4AH_Y7EubXBLAQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vovo Yang <vovoy@chromium.org>
Cc: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, Michal Hocko <mhocko@suse.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

On 11/2/18 6:22 AM, Vovo Yang wrote:
> On Thu, Nov 1, 2018 at 10:30 PM Dave Hansen <dave.hansen@intel.com> wrote:
>> On 11/1/18 5:06 AM, Vovo Yang wrote:
>>>> mlock() and ramfs usage are pretty easy to track down.  /proc/$pid/smaps
>>>> or /proc/meminfo can show us mlock() and good ol' 'df' and friends can
>>>> show us ramfs the extent of pinned memory.
>>>>
>>>> With these, if we see "Unevictable" in meminfo bump up, we at least have
>>>> a starting point to find the cause.
>>>>
>>>> Do we have an equivalent for i915?
> Chris helped to answer this question:
> Though it includes a few non-shmemfs objects, see
> debugfs/dri/0/i915_gem_objects and the "bound objects".
> 
> Example i915_gem_object output:
>   591 objects, 95449088 bytes
>   55 unbound objects, 1880064 bytes
>   533 bound objects, 93040640 bytes

Do those non-shmemfs objects show up on the unevictable list?  How far
can the amount of memory on the unevictable list and the amount
displayed in this "bound objects" value diverge?
