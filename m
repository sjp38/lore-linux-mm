Date: Tue, 26 Aug 2003 11:34:29 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [BUG] 2.6.0-test4-mm1: NFS+XFS=data corruption
Message-Id: <20030826113429.1440b0d0.akpm@osdl.org>
In-Reply-To: <1061920640.25889.1404.camel@jen.americas.sgi.com>
References: <20030824171318.4acf1182.akpm@osdl.org>
	<20030825193717.GC3562@ip68-4-255-84.oc.oc.cox.net>
	<20030825124543.413187a5.akpm@osdl.org>
	<1061852050.25892.195.camel@jen.americas.sgi.com>
	<20030826031412.72785b15.akpm@osdl.org>
	<20030826110111.GA4750@in.ibm.com>
	<20030826104458.448d1eea.akpm@osdl.org>
	<1061920640.25889.1404.camel@jen.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Lord <lord@sgi.com>
Cc: suparna@in.ibm.com, barryn@pobox.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

Steve Lord <lord@sgi.com> wrote:
>
>  Does rpm use readv/writev though? Or does the nfs server? not sure
>  how this change would affect the original problem report.

The NFS server uses multisegment writev.  RPM was running at the other end
of the ethernet, so it doesn't really matter what sort of write RPM
is issuing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
