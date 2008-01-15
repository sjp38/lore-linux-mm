Date: Tue, 15 Jan 2008 17:59:25 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC][PATCH 4/5] memory_pressure_notify() caller
Message-ID: <20080115175925.215471e1@bree.surriel.com>
In-Reply-To: <cfd9edbf0801151455j48669850s7ea4fe589dbb9710@mail.gmail.com>
References: <20080115092828.116F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080115100124.117B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<cfd9edbf0801151455j48669850s7ea4fe589dbb9710@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel =?UTF-8?B?U3DDpW5n?= <daniel.spang@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jan 2008 23:55:17 +0100
"Daniel SpAJPYng" <daniel.spang@gmail.com> wrote:

> The notification fires after only ~100 MB allocated, i.e., when page
> reclaim is beginning to nag from page cache. Isn't this a bit early?
> Repeating the test with swap enabled results in a notification after
> ~600 MB allocated, which is more reasonable and just before the system
> starts to swap.

Your issue may have more to do with the fact that the
highmem zone is 128MB in size and some balancing issues
between __alloc_pages and try_to_free_pages.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
