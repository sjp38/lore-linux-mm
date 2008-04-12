Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3C0QvlI031960
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 20:26:57 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3C0QwPS313206
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 20:26:58 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3C0Qv2o030339
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 20:26:57 -0400
Date: Fri, 11 Apr 2008 17:27:05 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
Message-ID: <20080412002705.GB26388@us.ibm.com>
References: <20080411234449.GE19078@us.ibm.com> <20080411234712.GF19078@us.ibm.com> <20080411234743.GG19078@us.ibm.com> <20080411234913.GH19078@us.ibm.com> <20080411235648.GA13276@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080411235648.GA13276@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <gregkh@suse.de>
Cc: wli@holomorphy.com, clameter@sgi.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On 11.04.2008 [16:56:48 -0700], Greg KH wrote:
> On Fri, Apr 11, 2008 at 04:49:13PM -0700, Nishanth Aravamudan wrote:
> > /sys/devices/system/node represents the current NUMA configuration of
> > the machine, but is undocumented in the ABI files. Add bare-bones
> > documentation for these files.
> > 
> > Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> > 
> > ---
> > Greg, is something like this what you'd want?
> 
> Yes it is, thanks for doing it.

Ok, good.

> > Should I be striving for more detail?
> 
> You might want to show what you mean by "list of nodes".  But other than
> that, this is a great start.

Yeah, I was thinking for a few of the files, an example output might
clarify their use{,fulness}.

> > Should the file have a preamble indicating none of it exists if !NUMA?
> 
> Yes, that would be helpful for people who might worry that they do not
> see these files :)

Ok, I'll make that change in the next version.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
