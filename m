Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: ZONE_NORMAL exhaustion (dcache slab)
Date: Thu, 24 Oct 2002 07:35:48 -0400
References: <3DB4C87E.7CF128F3@digeo.com> <2622146086.1035233637@[10.10.2.3]>
In-Reply-To: <2622146086.1035233637@[10.10.2.3]>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200210240735.48973.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@digeo.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I just experienced this problem on UP with 513M memory.  About 400m was 
locked in dentries.  The system was very unresponsive - suspect it was
spending gobs of time scaning unfreeable dentries.  This was with -mm3
up about 24 hours.

The inode caches looked sane.  Just the dentries were out of wack.

Ed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
