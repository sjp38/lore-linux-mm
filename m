Subject: Re: 2.5.64-mm6
From: Jeremy Fitzhardinge <jeremy@goop.org>
In-Reply-To: <20030313032615.7ca491d6.akpm@digeo.com>
References: <20030313032615.7ca491d6.akpm@digeo.com>
Content-Type: text/plain
Message-Id: <1047572586.1281.1.camel@ixodes.goop.org>
Mime-Version: 1.0
Date: 13 Mar 2003 08:23:06 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2003-03-13 at 03:26, Andrew Morton wrote:
>   This means that when an executable is first mapped in, the kernel will
>   slurp the whole thing off disk in one hit.  Some IO changes were made to
>   speed this up.

Does this just pull in text and data, or will it pull any debug sections
too?  That could fill memory with a lot of useless junk.

	J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
