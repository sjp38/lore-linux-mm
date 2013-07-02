Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 0A0C46B0032
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 08:42:10 -0400 (EDT)
Date: Tue, 2 Jul 2013 14:42:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: PROBLEM: Processes writing large files in memory-limited LXC
 container are killed by OOM
Message-ID: <20130702124208.GF16815@dhcp22.suse.cz>
References: <CAMcjixYa-mjo5TrxmtBkr0MOf+8r_iSeW5MF4c8nJKdp5m+RPA@mail.gmail.com>
 <20130701180101.GA5460@ac100>
 <20130701184503.GG17812@cmpxchg.org>
 <20130701190222.GA10367@sergelap>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130701190222.GA10367@sergelap>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Serge Hallyn <serge.hallyn@ubuntu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Aaron Staley <aaron@picloud.com>, containers@lists.linux-foundation.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 01-07-13 14:02:22, Serge Hallyn wrote:
> Quoting Johannes Weiner (hannes@cmpxchg.org):
[...]
> > OOM with too many dirty pages', included in 3.6+.
> 
> Is anyone actively working on the long term solution?

Patches for memcg dirty pages accounted were posted quite some time ago.
I plan to look at the at some point but I am rather busy with other
stuff right now. That would be just a first step though. Then we need to
hook into dirty pages throttling and make it memcg aware which sounds
like a bigger challenge.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
