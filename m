Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 590FD6B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 17:13:09 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id p10so21636487wes.9
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 14:13:08 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id do4si16596896wib.37.2015.01.12.14.13.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 14:13:08 -0800 (PST)
Date: Mon, 12 Jan 2015 17:13:01 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: add BUILD_BUG_ON() for string tables
Message-ID: <20150112221301.GA25609@phnom.home.cmpxchg.org>
References: <1421088863-14270-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421088863-14270-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 12, 2015 at 10:54:23AM -0800, Greg Thelen wrote:
> Use BUILD_BUG_ON() to compile assert that memcg string tables are in
> sync with corresponding enums.  There aren't currently any issues with
> these tables.  This is just defensive.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Looks good to me, thanks Greg.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
