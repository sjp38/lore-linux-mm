Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 0D0E46B008C
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 17:50:36 -0400 (EDT)
Date: Thu, 11 Jul 2013 14:50:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-] drop_caches-add-some-documentation-and-info-messsge.patch
 removed from -mm tree
Message-Id: <20130711145034.3ec774d0a44742cf5d8e1177@linux-foundation.org>
In-Reply-To: <20130711073644.GB21667@dhcp22.suse.cz>
References: <51ddc31f.zotz9WDKK3lWXtDE%akpm@linux-foundation.org>
	<20130711073644.GB21667@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, dave@linux.vnet.ibm.com, linux-mm@kvack.org

On Thu, 11 Jul 2013 09:36:44 +0200 Michal Hocko <mhocko@suse.cz> wrote:

> On Wed 10-07-13 13:25:03, Andrew Morton wrote:
> [...]
> > This patch was dropped because it has gone stale
> 
> Is there really a strong reason to not take this patch? 

I flushed out a whole bunch of MM patches which had been floating
around in indecisive limbo.

I don't recall all the review issues surrounding this one.  If you
think the patch is still good, please resend and ensure that the
changelog adequately addresses all the issues which were raised, so we
don't just take another trip around the loop.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
