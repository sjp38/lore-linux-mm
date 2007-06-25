Subject: Re: [RFC] mm-controller
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <467BFA47.4050802@linux.vnet.ibm.com>
References: <1182418364.21117.134.camel@twins>
	 <467A5B1F.5080204@linux.vnet.ibm.com> <1182433855.21117.160.camel@twins>
	 <467BFA47.4050802@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Mon, 25 Jun 2007 18:22:41 +0200
Message-Id: <1182788561.6174.70.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Cc: balbir@linux.vnet.ibm.com, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@in.ibm.com>, Pavel Emelianov <xemul@sw.ru>, Paul Menage <menage@google.com>, Kirill Korotaev <dev@sw.ru>, devel@openvz.org, Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Herbert Poetzl <herbert@13thfloor.at>, Roy Huang <royhuang9@gmail.com>, Aubrey Li <aubreylee@gmail.com>, riel@redhat
List-ID: <linux-mm.kvack.org>

On Fri, 2007-06-22 at 22:05 +0530, Vaidyanathan Srinivasan wrote:

> Merging both limits will eliminate the issue, however we would need
> individual limits for pagecache and RSS for better control.  There are
> use cases for pagecache_limit alone without RSS_limit like the case of
> database application using direct IO, backup applications and
> streaming applications that does not make good use of pagecache.

I'm aware that some people want this. However we rejected adding a
pagecache limit to the kernel proper on grounds that reclaim should do a
better job.

And now we're sneaking it in the backdoor.

If we're going to do this, get it in the kernel proper first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
