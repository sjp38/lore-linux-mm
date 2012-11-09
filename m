Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 1615C6B002B
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 19:42:20 -0500 (EST)
Received: by mail-yh0-f73.google.com with SMTP id i33so407242yhi.2
        for <linux-mm@kvack.org>; Thu, 08 Nov 2012 16:42:19 -0800 (PST)
From: Sonny Rao <sonnyrao@chromium.org>
Subject: [PATCHv2] mm: Fix calculation of dirtyable memory
Date: Thu,  8 Nov 2012 16:42:03 -0800
Message-Id: <1352421724-5366-1-git-send-email-sonnyrao@chromium.org>
In-Reply-To: <20121108153756.cca505da.akpm@linux-foundation.org>
References: <20121108153756.cca505da.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Fengguang Wu <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mandeep Singh Baines <msb@chromium.org>, Johannes Weiner <jweiner@redhat.com>, Olof Johansson <olofj@chromium.org>, Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>, Aaron Durbin <adurbin@chromium.org>

add apkm's suggestion

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
