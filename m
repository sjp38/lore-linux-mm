Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id BAA23604
	for <linux-mm@kvack.org>; Sat, 5 Oct 2002 01:22:26 -0700 (PDT)
Message-ID: <3D9EA140.BDE9803B@digeo.com>
Date: Sat, 05 Oct 2002 01:22:24 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: Breakout struct page
References: <1165733025.1033777103@[10.10.2.3]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> This very boring patch breaks out struct page into it's own header
> file.

Martin, I'm rather disinclined to be pushing any more cleanup
patches now.  They tend to directly subtract from the merge
rate of real stuff.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
