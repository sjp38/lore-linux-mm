From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14485.53937.931834.378699@dukat.scot.redhat.com>
Date: Mon, 31 Jan 2000 18:21:37 +0000 (GMT)
Subject: Re: Eliminating bounce buffers
In-Reply-To: <3895CAEF.B5078F0B@missioncriticallinux.com>
References: <3891C3E9.CD7B1A76@missioncriticallinux.com>
	<14485.49949.396513.567501@dukat.scot.redhat.com>
	<3895CAEF.B5078F0B@missioncriticallinux.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Larry Woodman <woodman@missioncriticallinux.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 31 Jan 2000 12:48:31 -0500, Larry Woodman
<woodman@missioncriticallinux.com> said:

> Yes, I totally agree that after we pass 4GB of physical memory we
> still need to copy to pages which are less than 4GB before doing IO.
> Do you think its worth having yet another zone for this???

Yes.  Ideally, on large PAE36 Intel boxes we want to use the memory
below 4G for uses which will require IO (ie. page cache), and memory
above that point for anonymous pages which we don't expect IO on except
if we start swapping.  Having separate zones will make that a lot easier
to arrange.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
