Date: Tue, 26 Aug 2003 10:44:58 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [BUG] 2.6.0-test4-mm1: NFS+XFS=data corruption
Message-Id: <20030826104458.448d1eea.akpm@osdl.org>
In-Reply-To: <20030826110111.GA4750@in.ibm.com>
References: <20030824171318.4acf1182.akpm@osdl.org>
	<20030825193717.GC3562@ip68-4-255-84.oc.oc.cox.net>
	<20030825124543.413187a5.akpm@osdl.org>
	<1061852050.25892.195.camel@jen.americas.sgi.com>
	<20030826031412.72785b15.akpm@osdl.org>
	<20030826110111.GA4750@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: suparna@in.ibm.com
Cc: lord@sgi.com, barryn@pobox.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

Suparna Bhattacharya <suparna@in.ibm.com> wrote:
>
>  > Binary searching reveals that the offending patch is
>  > O_SYNC-speedup-nolock-fix.patch
>  > 
> 
>  I'm not sure if this would help here, but there is
>  one bug which I just spotted which would affect writev from
>  XFS. I wasn't passing the nr_segs down properly.

That fixes it, thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
