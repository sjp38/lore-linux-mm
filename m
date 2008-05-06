Date: Mon, 5 May 2008 22:54:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm][PATCH 4/4] Add rlimit controller documentation
Message-Id: <20080505225434.3f81828b.akpm@linux-foundation.org>
In-Reply-To: <481FEF28.1000502@linux.vnet.ibm.com>
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain>
	<20080503213825.3140.4328.sendpatchset@localhost.localdomain>
	<20080505153509.da667caf.akpm@linux-foundation.org>
	<481FEF28.1000502@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, rientjes@google.com, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 06 May 2008 11:09:52 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > Ho hum, I had to do rather a lot of guesswork here to try to understand
> > your proposed overall design for this feature.  I'd prefer to hear about
> > your design via more direct means.
> 
> Do you have any suggestions on how to do that better. Would you like
> documentation to be the first patch in the series? I had sent out two RFC's
> earlier and got comments and feedback from several people.
> 

I do like to see the overall what-i-am-setting-out-to-do description in
there somewhere - sometimes a Docuemtation/ file is appropriate, other
times do it via changelog.

But the first part of the review is reviewing whatever it is which you set
out to achieve.  Once that's understood and sounds like a good idea then we
can start looking at how you did it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
