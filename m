Date: Mon, 14 Aug 2000 09:16:06 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: non-buffers writes
Message-ID: <20000814091606.I12218@redhat.com>
References: <3986D82A.CF9DEE2A@SANgate.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3986D82A.CF9DEE2A@SANgate.com>; from gabriel@SANgate.com on Tue, Aug 01, 2000 at 05:01:14PM +0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: BenHanokh Gabriel <gabriel@SANgate.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Aug 01, 2000 at 05:01:14PM +0300, BenHanokh Gabriel wrote:
> 
> how can i do direct writes to disk without the buffer-cache overhead?
> i failed to see any relevant flag to open() , nor any fnctl()

Via /dev/raw/raw* raw devices ("man raw").  We plan much more powerful
direct IO functionality for 2.5 (which should support O_DIRECT opening
of devices and regular files), but for now raw IO is the only
supported mechanism.

Cheers, 
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
