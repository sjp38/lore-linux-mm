Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 166AC6B0031
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 10:43:03 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id 10so5252283pdi.39
        for <linux-mm@kvack.org>; Tue, 09 Jul 2013 07:43:02 -0700 (PDT)
Date: Tue, 9 Jul 2013 07:42:59 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RFC] fsio: filesystem io accounting cgroup
Message-ID: <20130709144259.GF2478@htj.dyndns.org>
References: <20130708175201.GB9094@redhat.com>
 <20130708175607.GB18600@mtj.dyndns.org>
 <51DBC99F.4030301@openvz.org>
 <20130709125734.GA2478@htj.dyndns.org>
 <51DC0CE2.2050906@openvz.org>
 <20130709131605.GB2478@htj.dyndns.org>
 <20130709131646.GC2478@htj.dyndns.org>
 <51DC136E.6020901@openvz.org>
 <20130709134558.GD2478@htj.dyndns.org>
 <51DC1FCA.3060904@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51DC1FCA.3060904@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@gmail.com>, devel@openvz.org, Jens Axboe <axboe@kernel.dk>

On Tue, Jul 09, 2013 at 06:35:54PM +0400, Konstantin Khlebnikov wrote:
> I'm not interested in QoS or proportional control. Let schedulers do it.
> I want just bandwidth control. I don't want to write a new scheduler

Well, I'm not interested in adding more half-assed stuff on top of the
existing mess.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
