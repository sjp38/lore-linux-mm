Date: Thu, 24 Apr 2003 16:33:34 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: 2.5.68-mm2
Message-ID: <20030424163334.A12180@redhat.com>
References: <20030423233652.C9036@redhat.com> <Pine.LNX.3.96.1030424162101.11351C-100000@gatekeeper.tmr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.3.96.1030424162101.11351C-100000@gatekeeper.tmr.com>; from davidsen@tmr.com on Thu, Apr 24, 2003 at 04:24:56PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Davidsen <davidsen@tmr.com>
Cc: Andrew Morton <akpm@digeo.com>, "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 24, 2003 at 04:24:56PM -0400, Bill Davidsen wrote:
> Of course reasonable way may mean that bash does some things a bit slower,
> but given that the whole thing works well in most cases anyway, I think
> the kernel handling the situation is preferable.

Eh?  It makes bash _faster_ for all cases of starting up a child process.  
And it even works on 2.4 kernels.

		-ben
-- 
Junk email?  <a href="mailto:aart@kvack.org">aart@kvack.org</a>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
