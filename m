Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1D96A8E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 10:33:41 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c34so8956493edb.8
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 07:33:41 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j2-v6si1807441ejq.282.2018.12.17.07.33.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 07:33:39 -0800 (PST)
Date: Mon, 17 Dec 2018 16:33:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Cgroups support for THP
Message-ID: <20181217153338.GS30879@dhcp22.suse.cz>
References: <CAKhyrx-gbHjzWyeUERrXhH2CGMEMZeFX66Q-POD7Q+hKwWA1kw@mail.gmail.com>
 <20181217084836.GA22890@rapoport-lnx>
 <CAKhyrx8E+43Ddqq7eBD3eomKp-GYeqehmo_G7ZO=d+oAi7GOqQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKhyrx8E+43Ddqq7eBD3eomKp-GYeqehmo_G7ZO=d+oAi7GOqQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vijay nag <vijunag@gmail.com>
Cc: rppt@linux.ibm.com, linux-mm@kvack.org

On Mon 17-12-18 14:24:49, vijay nag wrote:
[...]
> Thanks for letting me know of this setting. However, there could be a
> third party daemons/processes that have THP in them. Do you think it is a
> good idea to make it cgroup aware ?

No, I do not really think this needs a cgroup support. Mostly because
the API scope for THP is way too complicated already and besides that
you can achieve what you want by setting PR_SET_THP_DISABLE and inherit
it down the road in your container.

-- 
Michal Hocko
SUSE Labs
