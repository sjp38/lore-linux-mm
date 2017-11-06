Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3DCBE6B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 12:11:53 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p75so3916590wmg.2
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 09:11:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z8si288249edi.549.2017.11.06.09.11.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 09:11:51 -0800 (PST)
Date: Mon, 6 Nov 2017 18:11:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Guaranteed allocation of huge pages (1G) using movablecore=N
 doesn't seem to work at all
Message-ID: <20171106171150.7a2lent6vdrewsk7@dhcp22.suse.cz>
References: <CACAwPwY0owut+314c5sy7jNViZqfrKy3sSf1hjLTocXefrz3xA@mail.gmail.com>
 <20171106130507.bm75uclqqoniqwdv@dhcp22.suse.cz>
 <CACAwPwZHH+TLov0hwYN-KWYowzk3yycj__GCfKH1MehPmuJ+Ow@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACAwPwZHH+TLov0hwYN-KWYowzk3yycj__GCfKH1MehPmuJ+Ow@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon 06-11-17 19:03:08, Maxim Levitsky wrote:
> I am fully aware of this.
> This is why we have /proc/vm/treat_hugepages_as_moveable which I did set.
> Did you remove this option?

Yes http://lkml.kernel.org/r/20171003072619.8654-1-mhocko@kernel.org

> I don't need/have memory hotplug so I am ok with huge pages beeing not
> movable in the movable zone.
> The idea here is that other pages in that zone should be moveable so I
> should be able to move all of them outside and replace them with hugepages.
> This clearly doesn't work here so thats why I am asking my question

This is an abuse of the zone movable. If we really want gigapages
movable then we should implement that. Maybe it would be as simple as
updating hugepage_migration_supported to support PUD pages. But this
requires some testing.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
