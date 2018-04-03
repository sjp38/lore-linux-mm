Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1F8606B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 06:50:52 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id i3so3241654wmf.7
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 03:50:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y187si1894266wmy.241.2018.04.03.03.50.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 03:50:50 -0700 (PDT)
Date: Tue, 3 Apr 2018 12:50:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: general protection fault in __mem_cgroup_free
Message-ID: <20180403105048.GK5501@dhcp22.suse.cz>
References: <001a113fe4c0a623b10568bb75ea@google.com>
 <20180403093733.GI5501@dhcp22.suse.cz>
 <20180403094329.GJ5501@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180403094329.GJ5501@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+8a5de3cce7cdc70e9ebe@syzkaller.appspotmail.com>
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com, Andrey Ryabinin <aryabinin@virtuozzo.com>

Here we go
