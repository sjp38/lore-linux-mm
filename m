Date: Tue, 24 Jun 2003 00:57:20 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.73-mm1
Message-Id: <20030624005720.06b2d3d0.akpm@digeo.com>
In-Reply-To: <200306241045.15886.kde@myrealbox.com>
References: <20030623232908.036a1bd2.akpm@digeo.com>
	<200306241045.15886.kde@myrealbox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "ismail (cartman) donmez" <kde@myrealbox.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"ismail (cartman) donmez" <kde@myrealbox.com> wrote:
>
> include/linux/mm.h: In function `lowmem_page_address':
>  include/linux/mm.h:344: error: `__PAGE_OFFSET' undeclared (first use in this 
>  function)

The configurable PAGE_OFFSET patch seems to confuse the build system sometimes.

Do another `make oldconfig', that should flush it out.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
