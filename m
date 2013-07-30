Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id B86DB6B0036
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 10:47:17 -0400 (EDT)
Date: Tue, 30 Jul 2013 16:47:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH resend] drop_caches: add some documentation and info
 message
Message-ID: <20130730144715.GH15847@dhcp22.suse.cz>
References: <1374842669-22844-1-git-send-email-mhocko@suse.cz>
 <20130729135743.c04224fb5d8e64b2730d8263@linux-foundation.org>
 <20130730074531.GA10584@dhcp22.suse.cz>
 <20130730012544.2f33ebf6.akpm@linux-foundation.org>
 <20130730125525.GB15847@dhcp22.suse.cz>
 <20130730073956.3047e3c7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130730073956.3047e3c7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, bp@suse.de, Dave Hansen <dave@linux.vnet.ibm.com>

On Tue 30-07-13 07:39:56, Andrew Morton wrote:
> On Tue, 30 Jul 2013 14:55:25 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > > > I am OK with that  but can we use a top bit instead. Maybe we never have
> > > > other entities to drop in the future but it would be better to have a room for them
> > > > just in case.
> > > 
> > > If we add another flag in the future it can use bit 3?
> > 
> > What if we get crazy and need more of them?
> 
> Then we use bit 4.  Then 5.  Then 6.
> 
> I'm really not understanding your point here ;)

I meant let's keep entities to drop in the low bits and the mode of
printing in the top so they are separated.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
