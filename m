Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 940DE6B004D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 15:59:47 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so5240213eaa.14
        for <linux-mm@kvack.org>; Tue, 27 Nov 2012 12:59:46 -0800 (PST)
Date: Tue, 27 Nov 2012 21:59:44 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 -mm] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121127205944.GB2433@dhcp22.suse.cz>
References: <20121123102137.10D6D653@pobox.sk>
 <20121123100438.GF24698@dhcp22.suse.cz>
 <20121125011047.7477BB5E@pobox.sk>
 <20121125120524.GB10623@dhcp22.suse.cz>
 <20121125135542.GE10623@dhcp22.suse.cz>
 <20121126013855.AF118F5E@pobox.sk>
 <20121126131837.GC17860@dhcp22.suse.cz>
 <50B403CA.501@jp.fujitsu.com>
 <20121127194813.GP24381@cmpxchg.org>
 <20121127205431.GA2433@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121127205431.GA2433@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>

Sorry, forgot to about one shmem charge:
---
