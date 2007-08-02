Date: Thu, 2 Aug 2007 09:44:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] 2.6.23-rc1-mm1 - fix missing numa_zonelist_order sysctl
Message-Id: <20070802094445.6495e25d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1185994972.5059.91.camel@localhost>
References: <1185994972.5059.91.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 01 Aug 2007 15:02:51 -0400
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> [But, maybe reordering the zonelists is not such a good idea
> when ZONE_MOVABLE is populated?]
> 

It's case-by-case I think. In zone order with ZONE_MOVABLE case,
user's page cache will not use ZONE_NORMAL until ZONE_MOVABLE in all node
is exhausted. This is an expected behavior, I think.

I think the real problem is the scheme for "How to set zone movable size to
appropriate value for the system". This needs more study and documentation.
(but maybe depends on system configuration to some extent.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
