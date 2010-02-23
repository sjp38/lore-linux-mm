Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A56196B0047
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 21:25:40 -0500 (EST)
Date: Tue, 23 Feb 2010 13:25:27 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2] Make VM_MAX_READAHEAD a kernel parameter
Message-ID: <20100223022527.GB22370@discord.disaster>
References: <201002091659.27037.knikanth@suse.de> <201002111715.04411.knikanth@suse.de> <20100214213724.GA28392@discord.disaster> <201002151006.37294.knikanth@suse.de> <20100221142600.GA10036@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100221142600.GA10036@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Nikanth Karthikesan <knikanth@suse.de>, Ankit Jain <radical@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Jens Axboe <jens.axboe@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sun, Feb 21, 2010 at 10:26:00PM +0800, Wu Fengguang wrote:
> Nikanth,
> 
> > > > +	readahead=	Default readahead value for block devices.
> > > > +
> > > 
> > > I think the description should define the units (kb) and valid value
> > > ranges e.g. page size to something not excessive - say 65536kb.  The
> > > above description is, IMO, useless without refering to the source to
> > > find out this information....
> > > 
> > 
> > The parameter can be specified with/without any suffix(k/m/g) that memparse() 
> > helper function can accept. So it can take 1M, 1024k, 1050620. I checked other 
> > parameters that use memparse() to get similar values and they didn't document 
> > it. May be this should be described here.
> 
> Hope this helps clarify things to user:
> 
> +       readahead=nn[KM]
> +                       Default max readahead size for block devices.
> +                       Range: 0; 4k - 128m

Yes, that is exactly what I was thinA,ing of. Thanks.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
