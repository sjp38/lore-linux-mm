Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 58A976B0037
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 09:33:56 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id um15so5040417pbc.28
        for <linux-mm@kvack.org>; Tue, 12 Mar 2013 06:33:55 -0700 (PDT)
Date: Tue, 12 Mar 2013 06:34:46 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] device: separate all subsys mutexes (was: Re: [BUG]
 potential deadlock led by cpu_hotplug lock (memcg involved))
Message-ID: <20130312133446.GA3514@kroah.com>
References: <513ECCFE.3070201@huawei.com>
 <20130312101555.GB30758@dhcp22.suse.cz>
 <20130312110750.GC30758@dhcp22.suse.cz>
 <20130312130504.GD30758@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130312130504.GD30758@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, LKML <linux-kernel@vger.kernel.org>, cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>

On Tue, Mar 12, 2013 at 02:05:04PM +0100, Michal Hocko wrote:
> The fix is quite simple. We can pull the key inside bus_type structure
> because they are defined per device so the pointer will be unique as
> well. bus_register doesn't need to be a macro anymore so change it
> to the inline. We could get rid of __bus_register as there is no other
> caller but maybe somebody will want to use a different key so keep it
> around for now.

Nice work, but just drop __bus_register(), no one should need to use a
new key for this type of thing, now that you have added a per-bus_type
variable.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
