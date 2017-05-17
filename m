Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 989FC6B02C4
	for <linux-mm@kvack.org>; Wed, 17 May 2017 08:23:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g143so2183925wme.13
        for <linux-mm@kvack.org>; Wed, 17 May 2017 05:23:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m24si2689964edd.79.2017.05.17.05.23.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 05:23:16 -0700 (PDT)
Date: Wed, 17 May 2017 14:23:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2 -v2] drm: drop drm_[cm]alloc* helpers
Message-ID: <20170517122312.GK18247@dhcp22.suse.cz>
References: <20170517065509.18659-1-mhocko@kernel.org>
 <20170517065509.18659-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170517065509.18659-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@intel.com>, Jani Nikula <jani.nikula@linux.intel.com>, Sean Paul <seanpaul@chromium.org>, David Airlie <airlied@linux.ie>

As it turned out my allyesconfig on x86_64 wasn't sufficient and 0day
build machinery found a failure on arm architecture. It was clearly a
typo. Now I have pushed this to my build battery with cross arch
compilers and it passes so there shouldn't more surprises hopefully.
Here is the v2.
---
