Date: Sun, 25 May 2003 13:06:37 -0400
From: Adam Kropelin <akropel1@rochester.rr.com>
Subject: Re: 2.5.69-mm9
Message-ID: <20030525130637.A22232@mail.kroptech.com>
References: <20030525042759.6edacd62.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030525042759.6edacd62.akpm@digeo.com>; from akpm@digeo.com on Sun, May 25, 2003 at 04:27:59AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 25, 2003 at 04:27:59AM -0700, Andrew Morton wrote:
> 
> . 2.5.69-mm9 is not for the timid.  It includes extensive changes to the
>   ext3 filesystem and the JBD layer.  It withstood an hour of testing on my
>   4-way, but it probably has a couple of holes still.

Felt like tempting fate today...

Works nicely here on my 2-way. Survives make -j30 (on a machine without
nearly enough RAM for such foolishness) as well as a basic mysql
stress-test.

--Adam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
