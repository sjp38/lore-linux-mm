Subject: Re: [BUG] 2.6.0-test4-mm1: NFS+XFS=data corruption
From: Steve Lord <lord@sgi.com>
In-Reply-To: <20030826104458.448d1eea.akpm@osdl.org>
References: <20030824171318.4acf1182.akpm@osdl.org>
	 <20030825193717.GC3562@ip68-4-255-84.oc.oc.cox.net>
	 <20030825124543.413187a5.akpm@osdl.org>
	 <1061852050.25892.195.camel@jen.americas.sgi.com>
	 <20030826031412.72785b15.akpm@osdl.org> <20030826110111.GA4750@in.ibm.com>
	 <20030826104458.448d1eea.akpm@osdl.org>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Message-Id: <1061920640.25889.1404.camel@jen.americas.sgi.com>
Mime-Version: 1.0
Date: 26 Aug 2003 12:57:21 -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: suparna@in.ibm.com, barryn@pobox.com, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 2003-08-26 at 12:44, Andrew Morton wrote:
> Suparna Bhattacharya <suparna@in.ibm.com> wrote:
> >
> >  > Binary searching reveals that the offending patch is
> >  > O_SYNC-speedup-nolock-fix.patch
> >  > 
> > 
> >  I'm not sure if this would help here, but there is
> >  one bug which I just spotted which would affect writev from
> >  XFS. I wasn't passing the nr_segs down properly.
> 
> That fixes it, thanks.

Does rpm use readv/writev though? Or does the nfs server? not sure
how this change would affect the original problem report.

Steve

-- 

Steve Lord                                      voice: +1-651-683-3511
Principal Engineer, Filesystem Software         email: lord@sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
