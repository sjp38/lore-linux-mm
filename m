Date: Thu, 17 Oct 2002 01:35:21 +0530
From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: Re: 2.5.42-mm2 hangs system
Message-ID: <20021017013521.A3024@in.ibm.com>
Reply-To: dipankar@in.ibm.com
References: <20021013160451.GA25494@hswn.dk> <3DA9CA28.155BA5CB@digeo.com> <20021013223332.GA870@hswn.dk> <20021016183907.B29405@in.ibm.com> <20021016154943.GA13695@hswn.dk> <20021016185908.GA863@hswn.dk> <20021017010103.C2380@in.ibm.com> <3DADC14A.5700CEC@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3DADC14A.5700CEC@digeo.com>; from akpm@digeo.com on Wed, Oct 16, 2002 at 12:43:06PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: =?iso-8859-1?Q?Henrik_St=F8rner?= <henrik@hswn.dk>, Maneesh Soni <maneesh@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 16, 2002 at 12:43:06PM -0700, Andrew Morton wrote:
> Is this dbench-on-NFS?  That has always failed - it's to do
> with the funny NFS handling of unlinked-while-open files.

Yes, it was.

I guess the thing to do would be to investigate NFS with dcache_rcu
and see where the don't mix. IIRC, this combination was tested a while ago, 
maybe 2.5.2x timeframe. We'll see.

Thanks
-- 
Dipankar Sarma  <dipankar@in.ibm.com> http://lse.sourceforge.net
Linux Technology Center, IBM Software Lab, Bangalore, India.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
