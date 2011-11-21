Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0A6616B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 08:24:12 -0500 (EST)
Date: Mon, 21 Nov 2011 21:24:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/8] readahead: make default readahead size a kernel
 parameter
Message-ID: <20111121132405.GA25093@localhost>
References: <20111121091819.394895091@intel.com>
 <20111121093846.251104145@intel.com>
 <8762id7h0a.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8762id7h0a.fsf@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Ankit Jain <radical@gmail.com>, Dave Chinner <david@fromorbit.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Nikanth Karthikesan <knikanth@suse.de>

> > +	readahead=nn[KM]
> > +			Default max readahead size for block devices.
> > +
> > +			This default max readahead size may be overrode
> 
> s/overrode/overridden/ ?

Ah sure. Good catch!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
