Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 38EAB6B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 06:40:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r16so9823228pfg.4
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 03:40:47 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id m187si36541819pga.271.2016.10.19.03.40.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Oct 2016 03:40:46 -0700 (PDT)
Message-ID: <1476873642.3387.2.camel@linux.intel.com>
Subject: Re: [Intel-gfx] [PATCH v4 2/2] drm/i915: Make GPU pages movable
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Date: Wed, 19 Oct 2016 13:40:42 +0300
In-Reply-To: <20161018133909.GE29358@nuc-i3427.alporthouse.com>
References: <1459775891-32442-1-git-send-email-chris@chris-wilson.co.uk>
	 <1459775891-32442-2-git-send-email-chris@chris-wilson.co.uk>
	 <1476792301.3117.14.camel@linux.intel.com>
	 <c733c4d9-de93-9a9b-1236-793cc26c8833@intel.com>
	 <20161018133909.GE29358@nuc-i3427.alporthouse.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, "Goel, Akash" <akash.goel@intel.com>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Sourab Gupta <sourab.gupta@intel.com>

On ti, 2016-10-18 at 14:39 +0100, Chris Wilson wrote:
> It's in my tree (on top of nightly) already with Joonas' r-b.

Patch 1/2 seems to have my comments already, could be addressed and
respined too.

Regards, Joonas
-- 
Joonas Lahtinen
Open Source Technology Center
Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
