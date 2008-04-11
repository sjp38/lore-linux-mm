Date: Fri, 11 Apr 2008 16:56:48 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
Message-ID: <20080411235648.GA13276@suse.de>
References: <20080411234449.GE19078@us.ibm.com> <20080411234712.GF19078@us.ibm.com> <20080411234743.GG19078@us.ibm.com> <20080411234913.GH19078@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080411234913.GH19078@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: wli@holomorphy.com, clameter@sgi.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, Apr 11, 2008 at 04:49:13PM -0700, Nishanth Aravamudan wrote:
> /sys/devices/system/node represents the current NUMA configuration of
> the machine, but is undocumented in the ABI files. Add bare-bones
> documentation for these files.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 
> ---
> Greg, is something like this what you'd want?

Yes it is, thanks for doing it.

> Should I be striving for more detail?

You might want to show what you mean by "list of nodes".  But other than
that, this is a great start.

> Should the file have a preamble indicating none of it exists if !NUMA?

Yes, that would be helpful for people who might worry that they do not
see these files :)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
