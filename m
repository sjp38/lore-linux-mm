Date: Wed, 10 Oct 2007 17:07:02 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: Memory controller merge (was Re: -mm merge plans for 2.6.24)
Message-ID: <20071010170702.34fb3eee@cuia.boston.redhat.com>
In-Reply-To: <4701C737.8070906@linux.vnet.ibm.com>
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
	<4701C737.8070906@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 02 Oct 2007 09:51:11 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> I was hopeful of getting the bare minimal infrastructure for memory
> control in mainline, so that review is easy and additional changes
> can be well reviewed as well.

I am not yet convinced that the way the memory controller code and
lumpy reclaim have been merged is correct.  I am combing through the
code now and will send in a patch when I figure out if/what is wrong.

I ran into this because I'm trying to merge the split VM code up to
the latest -mm...

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
