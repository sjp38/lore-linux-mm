Date: Fri, 25 Apr 2003 11:20:42 -0700
From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: 2.5.68-mm2
Message-Id: <20030425112042.37493d02.rddunlap@osdl.org>
In-Reply-To: <Pine.LNX.3.96.1030425135538.16623C-100000@gatekeeper.tmr.com>
References: <20030424163334.A12180@redhat.com>
	<Pine.LNX.3.96.1030425135538.16623C-100000@gatekeeper.tmr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Davidsen <davidsen@tmr.com>
Cc: bcrl@redhat.com, akpm@digeo.com, mbligh@aracnet.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 25 Apr 2003 13:56:31 -0400 (EDT) Bill Davidsen <davidsen@tmr.com> wrote:

| On Thu, 24 Apr 2003, Benjamin LaHaise wrote:
| 
| > On Thu, Apr 24, 2003 at 04:24:56PM -0400, Bill Davidsen wrote:
| > > Of course reasonable way may mean that bash does some things a bit slower,
| > > but given that the whole thing works well in most cases anyway, I think
| > > the kernel handling the situation is preferable.
| > 
| > Eh?  It makes bash _faster_ for all cases of starting up a child process.  
| > And it even works on 2.4 kernels.
| 
| The point is that even if bash is fixed it's desirable to address the
| issue in the kernel, other applications may well misbehave as well.

So when would this ever end?

--
~Randy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
