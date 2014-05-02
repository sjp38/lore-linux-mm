Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 400DC6B0036
	for <linux-mm@kvack.org>; Fri,  2 May 2014 07:22:33 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so3091401eek.10
        for <linux-mm@kvack.org>; Fri, 02 May 2014 04:22:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p8si1360047eew.36.2014.05.02.04.22.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 04:22:31 -0700 (PDT)
Date: Fri, 2 May 2014 13:22:29 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-ID: <20140502112229.GF3446@dhcp22.suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <20140430145910.c080164bc198485730d82ee0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140430145910.c080164bc198485730d82ee0@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed 30-04-14 14:59:10, Andrew Morton wrote:
> On Mon, 28 Apr 2014 14:26:41 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > The series is based on top of the current mmotm tree. Once the series
> > gets accepted I will post a patch which will mark the soft limit as
> > deprecated with a note that it will be eventually dropped. Let me know
> > if you would prefer to have such a patch a part of the series.
> 
> Yes please, we may as well get it all in there.
---
