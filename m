Subject: Re: [RFC] buddy allocator without bitmap [4/4]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <412DD452.1090703@jp.fujitsu.com>
References: <412DD452.1090703@jp.fujitsu.com>
Content-Type: text/plain
Message-Id: <1093535690.2984.22.camel@nighthawk>
Mime-Version: 1.0
Date: Thu, 26 Aug 2004 08:54:50 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-08-26 at 05:15, Hiroyuki KAMEZAWA wrote:
> This patch 5th inserts prefetch().
> I think These prefetch are reasonable and helpful.

Do you have any benchmark numbers to show it?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
