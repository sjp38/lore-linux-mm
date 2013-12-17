Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id 717FE6B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 02:48:22 -0500 (EST)
Received: by mail-yh0-f50.google.com with SMTP id b6so4627331yha.23
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 23:48:22 -0800 (PST)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id l26si15037415yhg.262.2013.12.16.23.48.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 23:48:21 -0800 (PST)
Received: by mail-pd0-f173.google.com with SMTP id p10so6426847pdj.18
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 23:48:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131216164730.GD26797@dhcp22.suse.cz>
References: <965cbb70fb55fe50a77382537b9a1b7455deac86.1387007793.git.vdavydov@parallels.com>
	<20131216164730.GD26797@dhcp22.suse.cz>
Date: Tue, 17 Dec 2013 11:48:20 +0400
Message-ID: <CAA6-i6rX7-F9UO2DO3gwC2SHNuSv2Fn48eLb1BZmc3HjCkbuvQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] memcg: fix memcg_size() calculation
From: Glauber Costa <glommer@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Glauber Costa <glommer@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Dec 16, 2013 at 8:47 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Sat 14-12-13 12:15:33, Vladimir Davydov wrote:
>> The mem_cgroup structure contains nr_node_ids pointers to
>> mem_cgroup_per_node objects, not the objects themselves.
>
> Ouch! This is 2k per node which is wasted. What a shame I haven't
> noticed this back then when reviewing 45cf7ebd5a033 (memcg: reduce the
> size of struct memcg 244-fold)
>
IIRC, they weren't pointers back then. I think they were embedded in
the structure, and I let
them embedded.
My mind may be tricking me, but I think I recall that Johannes changed
them to pointers
in a later time. No ?

In any case, this is correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
