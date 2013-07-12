Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 89D356B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 08:26:18 -0400 (EDT)
Date: Fri, 12 Jul 2013 14:25:57 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [-] drop_caches-add-some-documentation-and-info-messsge.patch
 removed from -mm tree
Message-ID: <20130712122557.GB24013@pd.tnic>
References: <51ddc31f.zotz9WDKK3lWXtDE%akpm@linux-foundation.org>
 <20130711073644.GB21667@dhcp22.suse.cz>
 <20130711145034.3ec774d0a44742cf5d8e1177@linux-foundation.org>
 <20130712115028.GC15307@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20130712115028.GC15307@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, Borislav Petkov <bp@suse.de>, Dave Hansen <dave.hansen@intel.com>

On Fri, Jul 12, 2013 at 01:50:28PM +0200, Michal Hocko wrote:
> Boris then noted
> (http://lkml.indiana.edu/hypermail/linux/kernel/1210.3/00659.html)
> that he is using drop_caches to make s2ram faster but as others noted
> this just adds the overhead to the resume path so it might work only
> for certain use cases so a user space solution is more appropriate and
> Boris' use case really sounds valid.

FWIW, I still use it. :-)

And we recently validated anew, a good use case for drop_caches which
was actually already mentioned - repeatable benchmark runs. In this
case, we show how *not* to use it in those benchmark runs. :)

http://marc.info/?l=linux-kernel&m=137276096923390

Thanks.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
