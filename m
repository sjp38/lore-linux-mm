Date: Tue, 4 Mar 2008 23:18:44 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 16/20] non-reclaimable mlocked pages
Message-ID: <20080304231844.499b5a03@bree.surriel.com>
In-Reply-To: <47CDE925.9090503@gmail.com>
References: <20080304225157.573336066@redhat.com>
	<20080304225227.780021971@redhat.com>
	<47CDE925.9090503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: minchan Kim <minchan.kim@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 05 Mar 2008 09:28:21 +0900
minchan Kim <minchan.kim@gmail.com> wrote:

> Hi, Rik.
> 
> There is a some trivial mistake.
> It can cause compile error.

Thank you.  I have applied your fix.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
