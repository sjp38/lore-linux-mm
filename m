Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id AAA06867
	for <linux-mm@kvack.org>; Tue, 4 Feb 2003 00:16:58 -0800 (PST)
Date: Tue, 4 Feb 2003 00:17:09 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.59-mm8
Message-Id: <20030204001709.5e2942e8.akpm@digeo.com>
In-Reply-To: <167540000.1044346173@[10.10.2.4]>
References: <20030203233156.39be7770.akpm@digeo.com>
	<167540000.1044346173@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> > http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-mm8/
> 
> Booted to login prompt, then immediately oopsed 
> (16-way NUMA-Q, mm6 worked fine). At a wild guess, I'd suspect 
> irq_balance stuff.
> 

There are a lot of scsi updates in Linus's tree.  Can you please
test just

http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-mm8/broken-out/linus.patch
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
