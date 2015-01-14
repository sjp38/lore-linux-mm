Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2237B6B006C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 09:06:13 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so9991538pdj.0
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 06:06:12 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id bs2si30979046pad.67.2015.01.14.06.06.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jan 2015 06:06:11 -0800 (PST)
Date: Wed, 14 Jan 2015 17:06:03 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch] mm: memcontrol: fold move_anon() and move_file()
Message-ID: <20150114140603.GD11264@esperanza>
References: <1421175592-14179-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1421175592-14179-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jan 13, 2015 at 01:59:52PM -0500, Johannes Weiner wrote:
> Turn the move type enum into flags and give the flags field a shorter
> name.  Once that is done, move_anon() and move_file() are simple
> enough to just fold them into the callsites.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
