Date: Thu, 24 Oct 2002 07:28:32 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: ZONE_NORMAL exhaustion (dcache slab)
Message-ID: <2833019656.1035444511@[10.10.2.3]>
In-Reply-To: <200210240735.48973.tomlins@cam.org>
References: <200210240735.48973.tomlins@cam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>, Andrew Morton <akpm@digeo.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> I just experienced this problem on UP with 513M memory.  About 400m was 
> locked in dentries.  The system was very unresponsive - suspect it was
> spending gobs of time scaning unfreeable dentries.  This was with -mm3
> up about 24 hours.
> 
> The inode caches looked sane.  Just the dentries were out of wack.

I think you want this:

+read-barrier-depends.patch
 RCU fix

Which is only in mm4 I believe. Wanna retest? mm4 is the first 44-mmX
that works for me ... seems to have quite a few bugfixes ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
