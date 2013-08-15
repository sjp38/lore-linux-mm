Return-Path: <owner-linux-mm@kvack.org>
Date: Thu, 15 Aug 2013 15:18:40 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC 0/3] Pin page control subsystem
In-Reply-To: <20130815044834.GB3139@gmail.com>
Message-ID: <00000140828ea17e-d69af79a-1d8e-4df2-9513-492df5e00afc-000000@email.amazonses.com>
References: <1376377502-28207-1-git-send-email-minchan@kernel.org> <00000140787b6191-ae3f2eb1-515e-48a1-8e64-502772af4700-000000@email.amazonses.com> <20130814001236.GC2271@bbox> <000001407dafbe92-7b2b4006-2225-4f0b-b23b-d66101a995aa-000000@email.amazonses.com>
 <20130814164705.GD2706@gmail.com> <000001407dc3c33b-4139d615-aecc-4745-a9b4-c84949f6a8f4-000000@email.amazonses.com> <20130815044834.GB3139@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, k.kozlowski@samsung.com, Seth Jennings <sjenning@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, guz.fnst@cn.fujitsu.com, Benjamin LaHaise <bcrl@kvack.org>, Dave Hansen <dave.hansen@intel.com>, lliubbo@gmail.com, aquini@redhat.com, Rik van Riel <riel@redhat.com>

On Thu, 15 Aug 2013, Minchan Kim wrote:

> Now mlock pages could be migrated in case of CMA so I think it's not a
> big problem to migrate it for other cases.
> I remember You and Peter argued what's the mlock semainc of pin POV
> and as I remember correctly, Peter said mlock doesn't mean pin so
> we could migrate it but you didn't agree. Right?

mlock means it can be migrated. Pinning is currently done by increasing
the page count. Migration will be attempted but it will fail since the
references cannot be all removed. Peter proposed that mlock would work
like pinning so that a migration of the page would not be attempted.

My concern is not only about migration but about a general way of pinning
pages. Having mlock and pinning with different semantics is already an
issue as the conversation with Peter brought out. Now we are
adding yet another way that pinning is used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
